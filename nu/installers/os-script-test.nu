#! /usr/bin/env nu

# OS script test - validates all installer functions are available

use ../share/utils.nu *

# Source all installer modules and check functions exist
export def main []: nothing -> nothing {
    slog "Testing installer function availability"

    # Core functions
    cmd-check core-install
    cmd-check essential-install

    cmd-check cli-slim-install
    cmd-check cli-install
    cmd-check cpp-install
    cmd-check vscode-binstall
    cmd-check terminal-binstall
    cmd-check emacs-binstall
    cmd-check ui-install
    cmd-check vm-install

    if not (is-atomic) and not (is-mac) {
        cmd-check docker-install
        cmd-check distrobox-install
        cmd-check incus-install
        cmd-check vm-ui-install
    }

    cmd-check dotfiles-install
    cmd-check pkgx-install
    cmd-check docker-install
    cmd-check pixi-install
    cmd-check brew-install
    cmd-check pixi-shell-slim-install
    cmd-check brew-shell-slim-install
    cmd-check pixi-shell-install
    cmd-check brew-shell-install
    cmd-check vscode-groupstall
    cmd-check python-install
    cmd-check shell-install

    if not (is-mac) {
        cmd-check fonts-install
        cmd-check starship-install
        cmd-check flathub-install
        cmd-check atomic-distrobox-install
        cmd-check apps-install
        cmd-check apps-slim-install
        cmd-check gnome-confstall

        cmd-check incus-confstall
        cmd-check libvirt-confstall
        cmd-check docker-confstall
    }

    cmd-check git-confstall
    cmd-check bash-confstall
    cmd-check zsh-min-confstall
    cmd-check zsh-confstall
    cmd-check ghostty-confstall
    cmd-check wezterm-confstall
    cmd-check kitty-confstall
    cmd-check tmux-confstall
    cmd-check emacs-confstall
    cmd-check nvim-confstall

    cmd-check generic-mainstall

    if (is-atomic) {
        return
    }

    cmd-check base-mainstall
    cmd-check min-mainstall
    cmd-check shell-slim-mainstall
    cmd-check shell-mainstall
    cmd-check vm-mainstall

    cmd-check nvim-boxstall
    cmd-check emacs-boxstall
    cmd-check tmux-boxstall
    cmd-check zsh-boxstall

    cmd-check slimbox-mainstall
    cmd-check box-mainstall
    cmd-check dt-mainstall
    cmd-check wslbox-mainstall
    cmd-check wsl-mainstall
    cmd-check centos-wsl-mainstall
    cmd-check fullbox-mainstall

    slog "All installer function checks passed!"
}
