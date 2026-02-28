#! /usr/bin/env nu

# Create a new user with sudo privileges in incus containers

use ./share/utils.nu *

# Get sudo group based on distro
export def get-sudo-group-for-distro [distro: string]: nothing -> string {
    match $distro {
        "ubuntu" | "debian" | "linuxmint" | "pop" | "elementary" | "zorin" | "kali" => { "sudo" }
        "fedora" | "rhel" | "centos" | "rocky" | "almalinux" => { "wheel" }
        "opensuse" | "opensuse-tumbleweed" | "suse" | "tumbleweed" => { "sudo" }
        "arch" | "manjaro" | "endeavouros" | "cachyos" | "garuda" => { "wheel" }
        _ => { die $"Unsupported distribution: ($distro)" }
    }
}

# Install sudo based on distro
export def install-sudo-for-distro [distro: string]: nothing -> nothing {
    match $distro {
        "ubuntu" | "debian" | "linuxmint" | "pop" | "elementary" | "zorin" | "kali" => {
            sudo apt-get update
            sudo apt-get install -y sudo
        }
        "fedora" | "rhel" | "centos" | "rocky" | "almalinux" => {
            sudo dnf install -y sudo
        }
        "opensuse" | "opensuse-tumbleweed" | "suse" | "tumbleweed" => {
            sudo zypper install -y sudo
        }
        "arch" | "manjaro" | "endeavouros" | "cachyos" | "garuda" => {
            sudo pacman -Sy --noconfirm sudo
        }
        _ => { warn $"Skipping sudo install for unknown distro: ($distro)" }
    }
}

# Check if sudoers entry exists
export def sudoers-entry-exists [sudo_group: string]: nothing -> bool {
    let sudoers_file = "/etc/sudoers"
    if not ($sudoers_file | path exists) {
        return false
    }
    let content = open $sudoers_file
    let pattern = $"%($sudo_group)\\s+ALL=\\(ALL(:ALL)?\\)\\s+ALL"
    ($content | find -r $pattern | is-not-empty)
}

# Main command
export def main [
    username?: string  # Username to create (optional, will prompt if not provided)
] {
    if not (is-root-user) {
        die "This script must be run as root"
    }

    # Get username from input or prompt
    let uname = if ($username | is-empty) {
        input "Enter new username: "
    } else {
        $username
    } | str trim

    if ($uname | is-empty) {
        die "Username cannot be empty"
    }

    # Check if user already exists
    let user_exists = try {
        ^id $uname | complete | get exit_code | $in == 0
    } catch {
        false
    }

    if $user_exists {
        die $"User '($uname)' already exists"
    }

    # Detect distro
    let distro = if ("/etc/os-release" | path exists) {
        open /etc/os-release
        | lines
        | parse "{key}={value}"
        | where key == "ID"
        | get 0?.value?
        | default "unknown"
        | str downcase
        | str trim -c '"'
    } else {
        die "Cannot detect OS type"
    }

    info $"Detected distro: ($distro)"

    let sudo_group = (get-sudo-group-for-distro $distro)

    # Create group if it doesn't exist
    if not (group-exists $sudo_group) {
        info $"Creating group '($sudo_group)'..."
        sudo groupadd $sudo_group
    }

    # Create user with sudo group
    sudo useradd -m -G $sudo_group -s /bin/bash $uname

    info $"Set password for user '($uname)':"
    sudo passwd $uname

    # Install sudo if not present
    if not (has-cmd sudo) {
        info "Installing sudo..."
        install-sudo-for-distro $distro
    }

    # Add sudoers entry if not exists
    if not (sudoers-entry-exists $sudo_group) {
        $"%($sudo_group) ALL=(ALL:ALL) ALL" | sudo tee -a /etc/sudoers | ignore
    }

    success $"User '($uname)' created and added to '($sudo_group)' group with sudo access"
}

