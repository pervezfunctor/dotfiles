#!/usr/bin/env nu

use utils.nu [is-root-user init-logs environs has-cmd select-multi slog die keep-sudo-running is-multipass is-distrobox]
use ../installers/mod.nu [shell-slim-install shell-install vscode-groupstall jetbrains-mono-install ptyxis-install docker-install npm-install vm-install apps-install incus-install nix-install brew-install pixi-install fonts-install tailscale-install nix-groupstall shell-groupstall vm-groupstall generic-mainstall generic-ct-mainstall fedora-atomic-mainstall]

const INSTALL_OPTIONS = [
    "shell-slim"
    "shell"
    "vscode"
    "jetbrains-mono"
    "ptyxis"
    "docker"
    "npm"
    "vm"
    "ptyxis"
    "apps"
    "incus"
    "nix"
    "brew"
    "pixi"
    "fonts"
    "tailscale"
    "@nix"
    "@shell"
    "@vm"
]

def print-help [] {
    print "Usage: ilmi [OPTION1] [OPTION2] ..."
    print "Options:"
    print "  shell-slim      essential shell packages."
    print "  shell           shell tools like zsh, tmux, nvim."
    print "  vscode          vscode and extensions."
    print "  jetbrains-mono  jetbrains mono nerd font."
    print "  ptyxis          ptyxis terminal."
    print "  docker          docker only"
    print "  npm             npm tools like pnpm, claude, gemini."
    print "  vm              vm tools like distrobox, libvirt, virt-manager."
    print "  ptyxis          ptyxis terminal."
    print "  apps            flatpak apps like zoom, obsidian, wezterm."
    print "  incus           incus and lxc."
    print "  nix             nix installation"
    print "  brew            homebrew for macos and linuxbrew for linux."
    print "  pixi            pixi for managing global packages and modern conda for python."
    print "  fonts           nerd fonts for jetbrains mono, cascadia code mono."
    print "  tailscale       tailscale for managing vpn."
    print ""
    print "Group Options"
    print "  @nix            nix installation"
    print "  @shell          min and shell tools and config for zsh, tmux, neovim."
    print "  @vm             vm tools like buildah, libvirt, virt-manager."
    print "  help            show this help."
    print "  -h, --help      show this help."
    print ""
}

def run-installer [option: string] {
    match $option {
        "shell-slim" => { shell-slim-install }
        "shell" => { shell-install }
        "vscode" => { vscode-groupstall }
        "jetbrains-mono" => { jetbrains-mono-install }
        "ptyxis" => { ptyxis-install }
        "docker" => { docker-install }
        "npm" => { npm-install }
        "vm" => { vm-install }
        "apps" => { apps-install }
        "incus" => { incus-install }
        "nix" => { nix-install }
        "brew" => { brew-install }
        "pixi" => { pixi-install }
        "fonts" => { fonts-install }
        "tailscale" => { tailscale-install }
        "@nix" => { nix-groupstall }
        "@shell" => { shell-groupstall }
        "@vm" => { vm-groupstall }
        "generic" => { generic-mainstall }
        "generic-ct" => { generic-ct-mainstall }
        "fedora-atomic" => { fedora-atomic-mainstall }
        _ => { die $"No such installer: ($option)" }
    }
}

def ilmi [...options: string] {
    for option in $options {
        run-installer $option
    }
}

def main [...args: string] {
    if (($args | is-not-empty) and ($args.0 in ["help" "-h" "--help"])) {
        print-help
        return
    }

    if (is-root-user) {
        print "This script must not be run as root. DO NOT use sudo."
        exit 1
    }

    environs
    rm -rf $env.ILM_LOG_DIR
    init-logs

    let disable_sudo = ((($args | is-not-empty) and ($args.0 in ["generic" "generic-ct" "fedora-atomic"])) or (is-multipass) or (is-distrobox))
    if $disable_sudo {
        $env.NOSUDO = 1
    } else {
        keep-sudo-running
    }

    if ($args | is-not-empty) {
        ilmi ...$args
        return
    }

    if not (has-cmd gum) and not (has-cmd fzf) {
        print-help
        return
    }

    let selected_options = (select-multi "Choose options to install" ...$INSTALL_OPTIONS)

    if ($selected_options | is-not-empty) {
        print ""
        slog $"Selected: ($selected_options | str join ' '). Installing..."
        print ""
        ilmi ...$selected_options
        slog "Installation complete."
    } else {
        slog "No options selected."
        exit 1
    }
}