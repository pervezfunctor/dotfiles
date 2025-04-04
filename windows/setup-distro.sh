#!/usr/bin/env bash

# Get username and password from arguments
username="$1"
password="$2"
distro_type="${3:-auto}" # auto-detect by default

if [ -z "$username" ] || [ -z "$password" ]; then
    echo "Error: Username and password must be provided"
    exit 1
fi

# Auto-detect distribution if not specified
if [ "$distro_type" = "auto" ]; then
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        distro_type="${ID}"
    else
        echo "Error: Could not detect distribution type"
        exit 1
    fi
fi

echo "Setting up $distro_type distribution..."

# Create user and set password based on distribution
create_user() {
    case "$distro_type" in
        centos*|rhel*|fedora*)
            useradd -m -G wheel "$username" 2>/dev/null || echo "User $username already exists"
            echo "$username:$password" | chpasswd
            echo '%wheel ALL=(ALL) ALL' > /etc/sudoers.d/wheel
            chmod 440 /etc/sudoers.d/wheel
            ;;
        ubuntu*|debian*)
            adduser --gecos "" --disabled-password "$username" 2>/dev/null || echo "User $username already exists"
            echo "$username:$password" | chpasswd
            usermod -aG sudo "$username"
            ;;
        opensuse*|suse*)
            useradd -m -G wheel "$username" 2>/dev/null || echo "User $username already exists"
            echo "$username:$password" | chpasswd
            echo '%wheel ALL=(ALL) ALL' > /etc/sudoers.d/wheel
            chmod 440 /etc/sudoers.d/wheel
            ;;
        *)
            echo "Unsupported distribution: $distro_type"
            exit 1
            ;;
    esac
}

# Set as default WSL user and enable systemd
configure_wsl() {
    echo -e '[user]\ndefault='"$username"'\n\n[boot]\nsystemd=true' > /etc/wsl.conf
}

# Install and configure SSH server
install_ssh() {
    case "$distro_type" in
        centos*|rhel*|fedora*)
            dnf install -y openssh-server
            ;;
        ubuntu*|debian*)
            apt-get update
            apt-get install -y openssh-server
            ;;
        opensuse*|suse*)
            zypper install -y openssh
            ;;
    esac

    # Configure SSH to allow password authentication
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

    # Start SSH service
    if [[ $(ps -p 1 -o comm=) == "systemd" ]]; then
        systemctl enable sshd
        systemctl start sshd
        echo "SSH service enabled and started with systemd"
    else
        /usr/sbin/sshd
        # Add SSH startup to appropriate shell config
        case "$distro_type" in
            centos*|rhel*|fedora*)
                if ! grep -q "pgrep sshd" /etc/bashrc; then
                    echo '[[ ! $(pgrep sshd) ]] && sudo /usr/sbin/sshd' >> /etc/bashrc
                fi
                ;;
            ubuntu*|debian*)
                if ! grep -q "pgrep sshd" /etc/bash.bashrc; then
                    echo '[[ ! $(pgrep sshd) ]] && sudo /usr/sbin/sshd' >> /etc/bash.bashrc
                fi
                ;;
            opensuse*|suse*)
                if ! grep -q "pgrep sshd" /etc/bash.bashrc; then
                    echo '[[ ! $(pgrep sshd) ]] && sudo /usr/sbin/sshd' >> /etc/bash.bashrc
                fi
                ;;
        esac
        echo "Started SSH service directly (systemd not available)"
    fi

    # Create SSH directory for the new user
    mkdir -p "/home/$username/.ssh"
    chmod 700 "/home/$username/.ssh"
    chown -R "$username:$username" "/home/$username/.ssh"
}

# Main execution
create_user
configure_wsl
install_ssh

# Display IP address for connection
echo "Setup complete!"
echo "You can connect to this instance via SSH:"
echo " ssh $username@$(hostname -I)"

# Run the setup script as the new user
echo "Running setup script as $username..."
sudo -u "$username" bash -c "cd /home/$username && bash -c \"\$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)\" -- $distro_type-wsl"
echo "Setup script complete!"
