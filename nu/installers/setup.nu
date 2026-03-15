#! /usr/bin/env nu

# Main setup entry point for installers
# Usage: setup <profile> [args...]

use ../share/utils.nu *
use common.nu *
use linux.nu *
use apt.nu *
use dnf.nu *
use arch.nu *
use tw.nu *
use alpine.nu *
use layered.nu *
use box.nu *
use mac.nu *
use mac-linux.nu *
use atomic.nu *

# Check if a function exists in the current scope
export def fn-exists [name: string]: nothing -> bool {
    installer-command-exists $name
}

export def resolve-installer-command [arg: string]: nothing -> any {
    if ($arg | str starts-with "@@") {
        let name = ($arg | str replace --regex '^@@' '')
        let fn_name = $"($name)-mainstall"
        if (fn-exists $fn_name) {
            return $fn_name
        }
    }

    if ($arg | str starts-with "@") {
        let name = ($arg | str replace --regex '^@' '')
        let fn_name = $"($name)-groupstall"
        if (fn-exists $fn_name) {
            return $fn_name
        }
    }

    for fn_name in [
        $"($arg)-install"
        $"($arg)-boxstall"
        $"($arg)-confstall"
        $"($arg)-groupstall"
        $"($arg)-mainstall"
        $"($arg)-binstall"
        $arg
    ] {
        if (fn-exists $fn_name) {
            return $fn_name
        }
    }

    die $"No such installer: ($arg)"
}

# Bootstrap function - initialize environment
export def bootstrap [...args: string]: nothing -> nothing {
    if (is-root-user) {
        die "This script must not be run as root. DO NOT use sudo."
    }

    environs
    reset-logs
    init-logs

    slog $"Bootstrapping, switching to directory ($env.HOME)"
    cd $env.HOME

    slog "Bootstrapping installer environment"

    # Set NOSUDO for certain environments
    let nosudo_envs = ["generic" "generic-ct" "fedora-atomic"]
    if ($args | is-not-empty) and ($args.0 in $nosudo_envs) {
        $env.NOSUDO = 1
    } else if (is-proxmox) or (is-ublue) or (is-multipass) or (is-distrobox) {
        $env.NOSUDO = 1
    }

    if ($env.NOSUDO? | is-empty) {
        keep-sudo-running
    }

    # Source the appropriate installer modules based on OS
    source-installers

    slog $"Installing ($args | str join ' ') ..."
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
    for arg in $args {
        let fn_name = (resolve-installer-command $arg)
        slog $"Running ($fn_name)"
        run-installer-command $fn_name
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
        run-installer-command $mainstall_fn
    } else {
        # Try min_mainstall as fallback
        if (fn-exists min-mainstall) {
            slog "Running min-mainstall"
            run-installer-command min-mainstall
        } else {
            die $"Unknown or unsupported profile: ($profile)"
        }
    }

    common-installer ...$rest_args

    if not (is-ublue) and (has-cmd zsh) and ((default-shell) != "zsh") {
        set-zsh-as-default
        zsh-confstall
    }
}
