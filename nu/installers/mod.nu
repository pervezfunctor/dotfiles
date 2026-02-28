#! /usr/bin/env nu

# Installer modules for dotfiles
# Usage: use installers.nu * or use installers.nu <command>

# Re-export all functions from submodules
export use setup.nu *
export use common.nu *
export use linux.nu *
export use apt.nu *
export use dnf.nu *
export use arch.nu *
export use tw.nu *
export use alpine.nu *
export use layered.nu *
export use box.nu *
export use mac.nu *
export use mac-linux.nu *

# Re-export os-script-test as a command
export use os-script-test.nu

# Main entry point for the installers module
export def main []: nothing -> nothing {
    echo "Usage: installers <command> [args...]"
    echo ""
    echo "Available installer groups:"
    echo "  base, min, shell-slim, shell, vm, work, desktop, nix"
    echo ""
    echo "Run 'installers setup <profile>' to start installation"
    echo ""
    echo "Available modules:"
    echo "  setup, common, linux, apt, dnf, arch, tw, alpine"
    echo "  layered, box, mac, mac-linux"
}
