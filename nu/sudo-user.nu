#! /usr/bin/env nu

# Create a new user with sudo privileges or add sudo privileges to an existing user

use ./share/utils.nu *

# Get the appropriate sudo group for the system
export def get-sudo-group []: nothing -> string {
    if (has-cmd apt-get) {
        "sudo"
    } else if (has-cmd dnf) {
        "wheel"
    } else if (has-cmd zypper) {
        "wheel"
    } else if (has-cmd pacman) {
        "wheel"
    } else {
        die "Unsupported system. Cannot determine package manager."
    }
}

# Install sudo package
export def install-sudo []: nothing -> nothing {
    if (has-cmd apt-get) {
        sudo apt-get update out> /dev/null
        sudo apt-get install -y sudo out> /dev/null
    } else if (has-cmd dnf) {
        sudo dnf install -y sudo out> /dev/null
    } else if (has-cmd zypper) {
        sudo zypper install -y sudo out> /dev/null
    } else if (has-cmd pacman) {
        sudo pacman -Sy --noconfirm sudo out> /dev/null
    } else {
        die "Unsupported system. Cannot determine package manager."
    }
}

# Add user to sudo group with verification
export def add-user-to-sudo-group [user: string, sudo_group: string]: nothing -> nothing {
    # Check if the sudo group exists, create it if it doesn't
    if not (group-exists $sudo_group) {
        slog $"Creating '($sudo_group)' group..."
        sudo groupadd $sudo_group
    }

    sudo usermod -aG $sudo_group $user

    if not (user-in-group $user $sudo_group) {
        warn $"Verification failed: User '($user)' was not added to group '($sudo_group)'"
    } else {
        slog $"User '($user)' successfully added to group '($sudo_group)'"
    }
}

# Main command
export def main [
    username: string  # Username to create or modify
    --help (-h)      # Show help message
] {
    if not (is-root-user) {
        die "This script must be run as root"
    }

    let sudo_group = (get-sudo-group)

    install-sudo

    # Check if user exists
    let user_exists = try {
        ^id $username | complete | get exit_code | $in == 0
    } catch {
        false
    }

    if $user_exists {
        slog $"User '($username)' already exists."
    } else {
        slog $"Creating new user '($username)'..."
        sudo useradd -m $username
    }

    # Set password
    sudo passwd $username

    add-user-to-sudo-group $username $sudo_group

    success $"($username) now has sudo privileges"
}

