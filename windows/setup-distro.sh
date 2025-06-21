#!/usr/bin/env bash

set -euo pipefail

# WSL Distribution Setup Script
# Sets up a new user with SSH access and configures WSL settings
# Usage: setup-distro.sh <username> <password> [distro_type]

# Constants
SCRIPT_NAME=""
SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_NAME

# Logging functions
log_info() {
    echo "[INFO] $*" >&2
}

log_error() {
    echo "[ERROR] $*" >&2
}

log_warn() {
    echo "[WARN] $*" >&2
}

# Usage function
usage() {
    cat <<EOF
Usage: $SCRIPT_NAME <username> <password> [distro_type]

Arguments:
    username     - Username to create
    password     - Password for the user
    distro_type  - Distribution type (auto-detect if not specified)
                   Supported: ubuntu, debian, fedora, centos, rhel, opensuse, suse

Examples:
    $SCRIPT_NAME myuser mypass
    $SCRIPT_NAME myuser mypass ubuntu
    $SCRIPT_NAME myuser mypass auto

EOF
}

# Validate arguments
if [[ $# -lt 2 ]] || [[ $# -gt 3 ]]; then
    log_error "Invalid number of arguments"
    usage
    exit 1
fi

# Get arguments with validation
readonly username="$1"
readonly password="$2"
readonly distro_type="${3:-auto}"

# Validate username format
if [[ ! "$username" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
    log_error "Invalid username format. Use lowercase letters, numbers, underscore, and hyphen only."
    exit 1
fi

# Validate password is not empty
if [[ -z "$password" ]]; then
    log_error "Password cannot be empty"
    exit 1
fi

# Detect distribution type
detect_distro() {
    local detected_distro=""

    if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        source /etc/os-release
        detected_distro="${ID:-unknown}"
    else
        log_error "Could not detect distribution type - /etc/os-release not found"
        exit 1
    fi

    echo "$detected_distro"
}

# Validate distribution type
validate_distro() {
    local distro="$1"
    case "$distro" in
    ubuntu | debian | fedora | centos | rhel | opensuse | suse)
        return 0
        ;;
    *)
        log_error "Unsupported distribution: $distro"
        log_info "Supported distributions: ubuntu, debian, fedora, centos, rhel, opensuse, suse"
        return 1
        ;;
    esac
}

# Auto-detect distribution if not specified
if [[ "$distro_type" = "auto" ]]; then
    detected_distro=$(detect_distro)
    readonly final_distro="$detected_distro"
else
    readonly final_distro="$distro_type"
fi

# Validate the distribution
if ! validate_distro "$final_distro"; then
    exit 1
fi

log_info "Setting up $final_distro distribution for user: $username"

# Check if user already exists
user_exists() {
    local user="$1"
    id "$user" &>/dev/null
}

# Create sudoers configuration for wheel group
setup_wheel_sudo() {
    local sudoers_file="/etc/sudoers.d/wheel"
    if [[ ! -f "$sudoers_file" ]]; then
        echo '%wheel ALL=(ALL) ALL' >"$sudoers_file"
        chmod 440 "$sudoers_file"
        log_info "Created wheel group sudo configuration"
    fi
}

# Create user and set password based on distribution
create_user() {
    log_info "Creating user: $username"

    if user_exists "$username"; then
        log_warn "User $username already exists, updating password and groups"
    fi

    case "$final_distro" in
    centos* | rhel* | fedora*)
        if ! user_exists "$username"; then
            useradd -m -G wheel "$username"
            log_info "Created user $username with wheel group membership"
        else
            usermod -aG wheel "$username"
            log_info "Added $username to wheel group"
        fi
        echo "$username:$password" | chpasswd
        setup_wheel_sudo
        ;;
    ubuntu* | debian*)
        if ! user_exists "$username"; then
            adduser --gecos "" --disabled-password "$username"
            log_info "Created user $username"
        fi
        echo "$username:$password" | chpasswd
        usermod -aG sudo "$username"
        log_info "Added $username to sudo group"
        ;;
    opensuse* | suse*)
        if ! user_exists "$username"; then
            useradd -m -G wheel "$username"
            log_info "Created user $username with wheel group membership"
        else
            usermod -aG wheel "$username"
            log_info "Added $username to wheel group"
        fi
        echo "$username:$password" | chpasswd
        setup_wheel_sudo
        ;;
    *)
        log_error "Unsupported distribution: $final_distro"
        exit 1
        ;;
    esac

    log_info "User $username configured successfully"
}

# Set as default WSL user and enable systemd
configure_wsl() {
    log_info "Configuring WSL settings"

    local wsl_conf="/etc/wsl.conf"
    cat >"$wsl_conf" <<EOF
[user]
default=$username

[boot]
systemd=true
EOF

    log_info "WSL configuration written to $wsl_conf"
    log_info "Default user set to: $username"
    log_info "Systemd enabled for faster boot times"
}

# Check if systemd is running
is_systemd_running() {
    [[ "$(ps -p 1 -o comm=)" == "systemd" ]]
}

# Install SSH server package
install_ssh_package() {
    log_info "Installing SSH server package"

    case "$final_distro" in
    centos* | rhel* | fedora*)
        if command -v dnf >/dev/null 2>&1; then
            dnf install -y openssh-server
        else
            yum install -y openssh-server
        fi
        ;;
    ubuntu* | debian*)
        apt-get update -qq
        apt-get install -y openssh-server
        ;;
    opensuse* | suse*)
        zypper install -y openssh
        ;;
    *)
        log_error "Unsupported distribution for SSH installation: $final_distro"
        return 1
        ;;
    esac

    log_info "SSH server package installed successfully"
}

# Configure SSH server settings
configure_ssh_server() {
    log_info "Configuring SSH server"

    local ssh_config="/etc/ssh/sshd_config"

    # Backup original config if it doesn't exist
    if [[ ! -f "${ssh_config}.backup" ]]; then
        cp "$ssh_config" "${ssh_config}.backup"
        log_info "Created backup of SSH config: ${ssh_config}.backup"
    fi

    # Enable password authentication
    if grep -q "^#PasswordAuthentication" "$ssh_config"; then
        sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' "$ssh_config"
    elif grep -q "^PasswordAuthentication" "$ssh_config"; then
        sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' "$ssh_config"
    else
        echo "PasswordAuthentication yes" >>"$ssh_config"
    fi

    log_info "SSH password authentication enabled"
}

# Start SSH service with systemd
start_ssh_systemd() {
    log_info "Starting SSH service with systemd"

    systemctl enable sshd
    systemctl start sshd

    if systemctl is-active --quiet sshd; then
        log_info "SSH service enabled and started successfully"
    else
        log_error "Failed to start SSH service"
        return 1
    fi
}

# Add SSH startup script for non-systemd systems
add_ssh_startup_script() {
    log_info "Adding SSH startup script for non-systemd system"

    # shellcheck disable=SC2016
    local startup_line='[ ! "$(pgrep sshd)" ] && sudo /usr/sbin/sshd'
    local config_file=""

    case "$final_distro" in
    centos* | rhel* | fedora*)
        config_file="/etc/bashrc"
        ;;
    ubuntu* | debian* | opensuse* | suse*)
        config_file="/etc/bash.bashrc"
        ;;
    esac

    if [[ -n "$config_file" ]] && [[ -f "$config_file" ]]; then
        if ! grep -q "pgrep sshd" "$config_file"; then
            # shellcheck disable=SC2016
            echo "$startup_line" >>"$config_file"
            log_info "Added SSH startup script to $config_file"
        else
            log_info "SSH startup script already exists in $config_file"
        fi
    fi
}

# Start SSH service directly (non-systemd)
start_ssh_direct() {
    log_info "Starting SSH service directly"

    if /usr/sbin/sshd; then
        log_info "SSH service started successfully"
        add_ssh_startup_script
    else
        log_error "Failed to start SSH service directly"
        return 1
    fi
}

# Setup SSH directory for user
setup_user_ssh_dir() {
    log_info "Setting up SSH directory for user: $username"

    local ssh_dir="/home/$username/.ssh"

    mkdir -p "$ssh_dir"
    chmod 700 "$ssh_dir"
    chown -R "$username:$username" "$ssh_dir"

    log_info "SSH directory created: $ssh_dir"
}

# Main SSH installation and configuration function
install_ssh() {
    log_info "Installing and configuring SSH server"

    # Install SSH package
    if ! install_ssh_package; then
        log_error "Failed to install SSH package"
        return 1
    fi

    # Configure SSH server
    configure_ssh_server

    # Start SSH service
    if is_systemd_running; then
        start_ssh_systemd
    else
        start_ssh_direct
    fi

    # Setup user SSH directory
    setup_user_ssh_dir

    log_info "SSH installation and configuration completed"
}

# Get IP address for SSH connection
get_ip_address() {
    local ip_address
    ip_address=$(hostname -I 2>/dev/null | awk '{print $1}')

    if [[ -z "$ip_address" ]]; then
        ip_address=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $7; exit}')
    fi

    if [[ -z "$ip_address" ]]; then
        ip_address="localhost"
    fi

    echo "$ip_address"
}

# Run external setup script
run_external_setup() {
    log_info "Running external setup script as user: $username"

    local setup_url="https://is.gd/egitif"
    local setup_args="${final_distro}-wsl"

    if ! sudo -u "$username" bash -c "cd /home/$username && timeout 300 bash -c \"\$(curl -sSL $setup_url || wget -qO- $setup_url)\" -- $setup_args"; then
        log_warn "External setup script failed or timed out"
        log_info "You can run it manually later with:"
        log_info "  bash -c \"\$(curl -sSL $setup_url)\" -- $setup_args"
        return 1
    fi

    log_info "External setup script completed successfully"
}

# Display completion message
show_completion_message() {
    local ip_address
    ip_address=$(get_ip_address)

    echo
    log_info "=== Setup Complete ==="
    log_info "Distribution: $final_distro"
    log_info "Username: $username"
    log_info "SSH enabled: Yes"
    log_info "Systemd enabled: Yes"
    echo
    log_info "You can connect to this instance via SSH:"
    log_info "  ssh $username@$ip_address"
    echo
    log_info "To restart WSL and apply systemd changes:"
    log_info "  wsl --shutdown"
    log_info "  wsl -d <distro-name>"
    echo
}

# Main execution function
main() {
    log_info "Starting WSL distribution setup"
    log_info "Target distribution: $final_distro"
    log_info "Target username: $username"

    # Execute setup steps
    create_user
    configure_wsl
    install_ssh

    # Show completion message
    show_completion_message

    # Run external setup (optional)
    if run_external_setup; then
        log_info "All setup steps completed successfully"
    else
        log_info "Basic setup completed, external setup failed"
    fi
}

# Run main function
main "$@"
