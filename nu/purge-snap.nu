#! /usr/bin/env nu

# Remove snap packages and prevent reinstallation

use ./share/utils.nu *

# Main command
export def main [
    --verbose (-v)  # Enable verbose output
] {
    if not (is-root-user) {
        die "This script must be run as root or with sudo"
    }

    if not (is-ubuntu) {
        die "This script is intended for Ubuntu systems only"
    }

    let required_commands = [snap apt systemctl rm]
    for cmd in $required_commands {
        if not (has-cmd $cmd) {
            die $"Required command not found: ($cmd)"
        }
        if $verbose {
            info $"Command found: ($cmd)"
        }
    }

    info "Listing installed snaps..."
    let snaps = try {
        ^snap list | lines | skip 1 | parse "{name} {version} {rev} {tracking} {publisher} {notes}" | get name
    } catch {
        []
    }

    if ($snaps | length) > 0 {
        info "Removing installed snaps..."
        for pkg in ($snaps | reverse) {
            info $"  -> Removing snap: ($pkg)"
            try {
                sudo snap remove --purge $pkg
            } catch {
                warn $"Failed to remove snap: ($pkg)"
            }
        }
    } else {
        info "No snaps installed"
    }

    info "Purging snapd package..."
    try {
        sudo apt purge -y snapd
    } catch {
        warn "Failed to purge snapd package"
    }

    info "Disabling and masking systemd services (if any)..."
    try {
        sudo systemctl disable --now snapd.service snapd.socket snapd.seeded.service
    } catch {}
    try {
        sudo systemctl mask snapd
    } catch {}

    info "Deleting leftover snap directories..."
    let snap_dirs = [
        ($env.HOME | path join "snap")
        "/snap"
        "/var/snap"
        "/var/lib/snapd"
        "/var/cache/snapd"
        "/var/log/snapd"
    ]

    for dir in $snap_dirs {
        if ($dir | path exists) {
            if $verbose {
                info $"Removing directory: ($dir)"
            }
            try {
                sudo rm -rf $dir
            } catch {
                warn $"Failed to remove directory: ($dir)"
            }
        } else {
            if $verbose {
                info $"Directory does not exist: ($dir)"
            }
        }
    }

    info "Creating APT preference to block snapd reinstallation..."
    let pref_dir = "/etc/apt/preferences.d"
    let pref_file = $pref_dir | path join "nosnap.pref"

    try {
        sudo mkdir -p $pref_dir
    } catch {
        die "Failed to create APT preferences directory"
    }

    let pref_content = "Package: snapd
Pin: release *
Pin-Priority: -10
"

    try {
        $pref_content | sudo tee $pref_file | ignore
    } catch {
        die "Failed to create APT preference file"
    }

    info "Refreshing package lists..."
    try {
        sudo apt update -y
    } catch {
        die "Failed to update package lists"
    }

    success "Snap has been completely removed and blocked from reinstalling"
}

