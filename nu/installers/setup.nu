#! /usr/bin/env nu

# Main setup entry point for installers
# Usage: setup <profile> [args...]

use ../share/utils.nu *

# Check if a function exists in the current scope
export def fn-exists [name: string]: nothing -> bool {
    scope commands | where name == $name | is-not-empty
}

# Bootstrap function - initialize environment
export def bootstrap [...args: string]: nothing -> nothing {
    slog "Bootstrapping installer environment"

    # Set NOSUDO for certain environments
    let nosudo_envs = ["generic" "generic-ct" "fedora-atomic"]
    if ($args | is-not-empty) and ($args.0 in $nosudo_envs) {
        $env.NOSUDO = 1
    } else if (is-proxmox) or (is-ublue) or (is-multipass) or (is-distrobox) {
        $env.NOSUDO = 1
    }

    # Source the appropriate installer modules based on OS
    source-installers
}

# Source all installer modules dynamically
export def source-installers []: nothing -> nothing {
    let installers_dir = ($env.DOT_DIR | path join "nu" "installers")

    if not (dir-exists $installers_dir) {
        warn $"Installers directory not found: ($installers_dir)"
        return
    }

    # The modules are loaded through 'use', so this is mostly for logging
    slog "Installer modules ready"
}

# Common installer wrapper that runs post-install checks
export def common-installer [...args: string]: nothing -> nothing {
    slog "Running common installer"

    # Set zsh as default if needed (only on Linux, not in atomic/ublue)
    if not (is-ublue) and (has-cmd zsh) and ((default-shell) != "zsh") {
        set-zsh-as-default
        zsh-confstall
    }
}

# Main entry point
export def main [...args: string]: nothing -> nothing {
    if ($args | is-empty) {
        fail "Usage: setup <profile> [args...]"
        exit 1
    }

    let profile = $args.0
    let rest_args = ($args | skip 1)

    bootstrap ...$args

    # Look for profile-specific mainstall function
    let mainstall_fn = $"($profile)-mainstall"

    if (fn-exists $mainstall_fn) {
        slog $"Running ($mainstall_fn)"
        run-external $mainstall_fn
        $rest_args | each { |arg| $arg }
    } else {
        # Try min_mainstall as fallback
        if (fn-exists min-mainstall) {
            min-mainstall
        } else {
            die $"Unknown or unsupported profile: ($profile)"
        }
    }

    common-installer ...$rest_args
}

# Default mainstall for unknown profiles
export def min-mainstall []: nothing -> nothing {
    slog "Running minimal installation"
}
