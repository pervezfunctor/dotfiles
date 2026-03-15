#!/usr/bin/env nu

use utils.nu [is-root-user init-logs environs has-cmd select-multi slog die]
use ../installers/mod.nu [zsh-confstall tmux-confstall nvim-confstall vscode-confstall emacs-confstall git-confstall docker-confstall libvirt-confstall gnome-confstall sway-confstall hyprland-confstall incus-confstall rofi-confstall ghostty-confstall vscode-flatpak-confstall]

const INSTALL_OPTIONS = [
    "zsh"
    "tmux"
    "nvim"
    "vscode"
    "emacs"
    "git"
    "docker"
    "libvirt"
    "gnome"
    "sway"
    "hyprland"
    "incus"
    "rofi"
    "ghostty"
    "vscode-flatpak"
]

def print-help [] {
    print "Usage: ilmc [OPTION1] [OPTION2] ..."
    print "Options:"
    print "  zsh             zsh config with starship prompt and common plugins."
    print "  tmux            tmux config, catppuccin theme and common plugins."
    print "  nvim            lazyvim based config and plugins."
    print "  vscode          vscode settings and extensions."
    print "  emacs           doom emacs config."
    print "  git             git basic config."
    print "  docker          docker config to use without sudo."
    print "  libvirt         libvirt config to use without sudo."
    print "  gnome           gnome config and extensions."
    print "  sway            sway config with modern desktop tools."
    print "  hyprland        hyprland config with modern desktop tools."
    print "  incus           incus config to use without sudo."
    print "  rofi            rofi-wayland config."
    print "  ghostty         ghostty config."
    print "  vscode-flatpak  vscode flatpak config."
    print "  help            show this help."
    print "  -h, --help      show this help."
    print ""
}

def run-confstall [option: string] {
    match $option {
        "zsh" => { zsh-confstall }
        "tmux" => { tmux-confstall }
        "nvim" => { nvim-confstall }
        "vscode" => { vscode-confstall }
        "emacs" => { emacs-confstall }
        "git" => { git-confstall }
        "docker" => { docker-confstall }
        "libvirt" => { libvirt-confstall }
        "gnome" => { gnome-confstall }
        "sway" => { sway-confstall }
        "hyprland" => { hyprland-confstall }
        "incus" => { incus-confstall }
        "rofi" => { rofi-confstall }
        "ghostty" => { ghostty-confstall }
        "vscode-flatpak" => { vscode-flatpak-confstall }
        "help" | "-h" | "--help" => { print-help }
        _ => { die $"No such config: ($option)" }
    }
}

def ilmc [...options: string] {
    for option in $options {
        if ($option in ["help" "-h" "--help"]) {
            print-help
            return
        }

        run-confstall $option
    }
}

def main [...args: string] {
    if (is-root-user) {
        print "This script must not be run as root. DO NOT use sudo."
        exit 1
    }

    rm -rf $env.ILM_LOG_DIR
    init-logs
    environs

    if ($args | is-not-empty) {
        ilmc ...$args
        return
    }

    if not (has-cmd gum) and not (has-cmd fzf) {
        print-help
        return
    }

    let selected_options = (select-multi "Choose options to install" ...$INSTALL_OPTIONS)

    if ($selected_options | is-not-empty) {
        print ""
        slog $"Selected: ($selected_options | str join ' '). Configuring..."
        print ""
        ilmc ...$selected_options
        slog "Configuration complete."
    } else {
        slog "No options selected."
        exit 1
    }
}
