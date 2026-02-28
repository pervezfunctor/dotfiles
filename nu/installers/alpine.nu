#! /usr/bin/env nu

# Alpine Linux (APK) installer functions

use ../share/utils.nu *
use common.nu *

# asroot helper
export def asroot [...args: string]: nothing -> nothing {
    if (has-cmd sudo) {
        sudo ...$args
    } else if (has-cmd doas) {
        doas ...$args
    }
}

# Main package install function
export def si [...packages: string]: nothing -> nothing {
    asroot apk add --no-cache ...$packages
}

# Update packages
export def update-packages []: nothing -> nothing {
    slog "Updating Alpine"

    if not ({ asroot apk update && asroot apk upgrade } | complete | get exit_code | $in == 0) {
        die "apk update/upgrade failed, quitting"
    }
}

# Alpine packages installation
export def alpine-packages []: nothing -> nothing {
    asroot apk add --no-cache curl wget gcc libc-dev make gzip zsh git unzip \
        neovim tmux ripgrep luarocks fzf eza zoxide github-cli delta bat nmap \
        trash-cli starship stow just file tree fd htop sd net-tools iproute2 \
        bottom choose dialog direnv dust dysk delta gum jq lazygit libsecret micro \
        pixi procs shellcheck shfmt stow tar tldr ugrep which xh yazi yq newt
}

# Locale setup
export def locale-setup []: nothing -> nothing {
    let locale = "en_US.UTF-8"
    let keymap = "us"

    echo $"($locale) UTF-8" | sudo tee -a /etc/locale.gen | ignore
    echo $"LANG=($locale)" | sudo tee /etc/locale.conf | ignore
    asroot setup-keymap $keymap
}

# Core installation
export def core-install []: nothing -> nothing {
    update-packages

    slog "Installing core packages"

    si gpg curl wget git trash-cli tree tar unzip stow zstd file

    slog "Core packages installation done!"
}

# System Python installation
export def system-python-install []: nothing -> nothing {
    slog "Installing python"

    si python3 py3-virtualenv pipx uv python python-pip python-pipx python-uv

    slog "Python installation done!"

    cmd-check uv
}

# Essential installation
export def essential-install []: nothing -> nothing {
    slog "Installing essential packages"

    pkgx-install
    system-python-install

    si zip micro p7zip net-tools iproute2 nmap gcc make fzf gawk just tmux \
        readline newt sqlite libffi zlib pkgfile gawk

    slog "Essential packages installation done!"
}

# CLI slim installation
export def cli-slim-install []: nothing -> nothing {
    slog "Installing cli tools using apt"

    si zsh github-cli fzf ripgrep zoxide eza starship

    slog "cli tools installation done!"
}

# CLI installation
export def cli-install []: nothing -> nothing {
    slog "Installing cli tools using apt"

    asroot apk add neovim tmux shellcheck shfmt zsh-completions bat jq yq luarocks \
        lazygit ugrep delta navi sd gdu hyperfine fd lsd xh htop nushell bottom \
        plocate dysk yazi procs dust direnv atuin broot glances curlie choose just \
        dialog lazydocker

    slog "cli tools installation done!"
}

# C++ installation
export def cpp-install []: nothing -> nothing {
    slog "Installing C++"

    si libstdc++ libc6-compat python3 g++ bash emacs clang-analyzer lldb lld \
        clang-ccache clang-extra-tools llvm gcc gdb g++ catch2 clang llvm \
        clang-extra-tools ccache cppcheck pre-commit valgrind ltrace strace \
        cmake

    conan-install

    cmd-check gcc g++ gdb clang clang-tidy clang-format
    cmd-check cmake conan

    slog "C++ installation done!"
}

# Terminal binary installation
export def terminal-binstall []: nothing -> nothing {
    if (has-cmd kitty) {
        return
    }

    slog "Installing terminal"

    si kitty

    slog "terminal installation done!"
}

# UI installation
export def ui-install []: nothing -> nothing {
    if not (is-desktop) {
        return
    }

    slog "Installing ui"

    si gnome-keyring wl-clipboard flatpak
    flathub-install

    slog "ui installation done!"
}

# Libvirt configuration
export def libvirt-confstall []: nothing -> nothing {
    asroot rc-update add libvirtd default
    asroot service libvirtd start
}

# VM installation
export def vm-install []: nothing -> nothing {
    slog "Installing libvirt"

    si libvirt virt-install bridge-utils dnsmasq libosinfo openssl virglrenderer \
        libisoburn cloud-utils dmidecode jq qemu-hw-display-virtio-gpu libosinfo \
        xmlstarlet ovmf osinfo-db osinfo-db-tools

    slog "libvirt installation done!"
}

# VM UI installation
export def vm-ui-install []: nothing -> nothing {
    if not (is-desktop) {
        return
    }

    slog "Installing virt ui packages"

    let pkgs = []
    let pkgs = if not (has-cmd gnome-boxes) { $pkgs | append gnome-boxes } else { $pkgs }
    let pkgs = if (has-cmd virt-install) { $pkgs | append [virt-manager virt-viewer] } else { $pkgs }

    si ...$pkgs

    slog "virt ui packages installation done!"
}

# Incus installation
export def incus-install []: nothing -> nothing {
    if (has-cmd incus) {
        return
    }

    slog "Installing incus"

    si incus incus-vm openssl bridge-utils
    incus-confstall

    slog "incus installation done!"
}

# Distrobox installation
export def distrobox-install []: nothing -> nothing {
    if (has-cmd distrobox) {
        return
    }

    slog "Installing distrobox"
    si podman podman-compose buildah distrobox
    slog "distrobox installation done!"
}

# Docker configuration
export def docker-confstall []: nothing -> nothing {
    asroot rc-update add docker default
    asroot service docker start

    asroot addgroup $env.USER docker
}

# Docker installation
export def docker-install []: nothing -> nothing {
    if (has-cmd docker) {
        return
    }

    slog "Installing docker"

    si docker docker-compose

    slog "docker installation done!"
}
