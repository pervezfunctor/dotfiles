#! /usr/bin/env nu

# Linux-specific installer functions

use ../share/utils.nu *
use common.nu *

# Devbox installation
export def devbox-install []: nothing -> nothing {
    if (has-cmd devbox) {
        return
    }

    slog "Installing devbox"
    curl -fsSL https://get.jetify.com/devbox | bash

    slog "devbox installation done!"

    cmd-check devbox
}

# Nix installation without init
export def nix-no-init-install []: nothing -> nothing {
    if (has-cmd nix) {
        return
    }

    slog "Installing nix"
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install linux --init none
    slog "nix installation done!"

    cmd-check nix nix-shell nix-env
}

# Emacs binary installation
export def emacs-binstall []: nothing -> nothing {
    slog "Installing emacs"

    if (is-apt) {
        echo "postfix postfix/main_mailer_type select No configuration" | sudo debconf-set-selections
        si -y --no-install-recommends emacs
    } else if (is-mac) {
        brew tap railwaycat/emacsmacport
        brew install -q emacs-mac --with-modules
        ln -s /usr/local/opt/emacs-mac/Emacs.app /Applications/Emacs.app
    } else {
        si emacs
    }

    slog "emacs installation done!"

    cmd-check emacs
}

# Go installation
export def go-install []: nothing -> nothing {
    if not (has-cmd go) {
        slog "Installing go"

        sudo rm -rf /usr/local/go
        let version = (curl -sSL "https://go.dev/VERSION?m=text" | lines | first)
        frm $"/tmp/($version).linux-amd64.tar.gz"
        wget -nv $"https://dl.google.com/go/($version).linux-amd64.tar.gz" -O $"/tmp/($version).linux-amd64.tar.gz"
        slog $"Untar ($version).linux-amd64.tar.gz"
        sudo tar -C /usr/local -xzf $"/tmp/($version).linux-amd64.tar.gz"
        frm $"/tmp/($version).linux-amd64.tar.gz"
        $env.PATH = ($env.PATH | prepend "/usr/local/go/bin")

        slog "go installation done!"
    }

    if not (has-cmd go) {
        warn "go not installed, skipping go dev tools"
        return
    }

    go-tools-install

    slog "go dev tools installation done!"
}

# Multipass installation
export def multipass-install []: nothing -> nothing {
    if not (has-cmd snap) {
        snap-install
    }

    if (has-cmd snap) {
        sudo snap install multipass
    } else {
        warn "snap not installed, skipping multipass installation"
    }
}

# VSCode groupstall for Linux
export def vscode-groupstall []: nothing -> nothing {
    # Call OS-specific vscode_binstall
    let vscode_fn = (scope commands | where name == vscode-binstall | is-not-empty)
    if $vscode_fn {
        vscode-binstall
    }
    jetbrains-mono-install
    vscode-confstall
}

# Prog group check
export def prog-group-check []: nothing -> nothing {
    cmd-check go rustc npm uv pyenv conda
}

# VT mainstall (VM + Incus + Distrobox)
export def vt-mainstall []: nothing -> nothing {
    vm-mainstall
    incus-groupstall
    distrobox-groupstall
}

# Prog mainstall
export def prog-mainstall []: nothing -> nothing {
    vm-mainstall
    go-install
    rust-install
    npm-install
    prog-group-check
}

# All group check
export def all-group-check []: nothing -> nothing {
    cmd-check pixi emacs
}

# All mainstall
export def all-mainstall []: nothing -> nothing {
    prog-mainstall
    pixi-install
    pkgx-install

    emacs-binstall
    emacs-confstall

    all-group-check
}

# Sway mainstall
export def sway-mainstall []: nothing -> nothing {
    slog "Installing sway"
    shell-mainstall

    sway-install

    slog "sway instalation done!"
}

# Hyprland mainstall
export def hyprland-mainstall []: nothing -> nothing {
    slog "Installing hyprland"
    shell-mainstall

    hyprland-install

    slog "hyprland instalation done!"
}

# Docker installation
export def docker-install []: nothing -> nothing {
    if (has-cmd docker) {
        return
    }

    slog "Installing docker..."

    frm /tmp/get-docker.sh
    curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
    sudo sh /tmp/get-docker.sh
    frm /tmp/get-docker.sh

    slog "Docker installation done!"
}

# Docker rootless installation
export def docker-rootless-install []: nothing -> nothing {
    curl -fsSL https://get.docker.com/rootless | sh
    $env.DOCKER_HOST = $"unix:///run/user/(id -u)/docker.sock"

    systemctl --user start docker
    systemctl --user enable docker
}

# Code server installation
export def code-server-install []: nothing -> nothing {
    if (has-cmd code-server) {
        return
    }

    slog "Installing code-server"
    curl -sSL https://code-server.dev/install.sh | sh
    slog "code-server installation done!"

    cmd-check code-server
}

# Coder installation
export def coder-install []: nothing -> nothing {
    slog "Installing coder"
    curl -L https://coder.com/install.sh | sh
    slog "coder installation done!"
}

# Permissive SELinux
export def permissive-selinux []: nothing -> nothing {
    sudo sed -i 's/^SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config

    sudo setenforce 0
    let current = (getenforce)
    if $current == "Permissive" {
        slog "Successfully set SELinux to permissive mode."
    } else {
        die "Failed to set SELinux to permissive mode. Quitting."
    }
}

# Foot configuration
export def foot-confstall []: nothing -> nothing {
    slog "foot config"
    stowgf foot
    slog "foot config done!"
}

# Pyenv installation
export def pyenv-install []: nothing -> nothing {
    if (has-cmd pyenv) {
        # eval "$(pyenv init -)" equivalent
        return
    }

    slog "Installing pyenv"
    sclone https://github.com/yyuu/pyenv.git ~/.pyenv
    sclone https://github.com/yyuu/pyenv-virtualenv.git ~/.pyenv/plugins/pyenv-virtualenv
    slog "pyenv installation done!"

    $env.PYENV_ROOT = "$HOME/.pyenv"
    $env.PATH = ($env.PATH | prepend "$PYENV_ROOT/bin")
    # pyenv init - equivalent would need to be handled

    cmd-check pyenv
}

# Tailscale installation
export def tailscale-install []: nothing -> nothing {
    if (has-cmd tailscale) {
        return
    }

    # Try package manager first
    let si_fn = (scope commands | where name == si | is-not-empty)
    if $si_fn {
        si tailscale
        if (has-cmd tailscale) {
            return
        }
    }

    if (has-cmd pixi) {
        pis tailscale
        return
    }

    if (has-cmd brew) {
        bis tailscale
        return
    }

    slog "Installing tailscale"
    curl -fsSL https://tailscale.com/install.sh | sh
    slog "tailscale installation done!"
}

# Sway installation
export def sway-install []: nothing -> nothing {
    slog "Installing sway..."

    let sway_fn = (scope commands | where name == sway-binstall | is-not-empty)
    if $sway_fn {
        sway-binstall
    }
    uv-install
    pyi i3ipc
    pyi autotiling

    slog "Installing sway done!"
}

# Sway groupstall
export def sway-groupstall []: nothing -> nothing {
    sway-install
    sway-confstall
}

# Hyprland installation
export def hyprland-install []: nothing -> nothing {
    slog "Installing hyprland..."

    let hypr_fn = (scope commands | where name == hyprland-binstall | is-not-empty)
    if $hypr_fn {
        hyprland-binstall
    }

    hyprland-confstall
    hypr-waybar-confstall
    kitty-confstall
    rofi-confstall
    wlogout-confstall

    slog "hyprland installation done!"
}

# Dev check
export def dev-check []: nothing -> nothing {
    shell-slim-check
    cmd-check code distrobox
}

# Dev mainstall
export def dev-mainstall []: nothing -> nothing {
    shell-slim-mainstall
    vscode-groupstall
    distrobox-install
    dev-check
}

# Dev-nix mainstall
export def dev-nix-mainstall []: nothing -> nothing {
    nix-mainstall
    vscode-groupstall
    jetbrains-mono-install
}

# Dev-work check
export def dev-work-check []: nothing -> nothing {
    dev-check
    cmd-check docker
}

# Dev-work mainstall
export def dev-work-mainstall []: nothing -> nothing {
    dev-mainstall
    docker-groupstall
    dev-work-check
}

# Dev-work-full check
export def dev-work-full-check []: nothing -> nothing {
    dev-work-check
    cmd-check incus
}

# Dev-work-full mainstall
export def dev-work-full-mainstall []: nothing -> nothing {
    dev-work-mainstall
    incus-install
}

# Distrobox Docker dev mainstall
export def dt-docker-dev-mainstall []: nothing -> nothing {
    if not (is-distrobox) {
        die "This script is only for Ubuntu distrobox container"
    }
    if not (is-ubuntu) {
        die "This script is only for Ubuntu distrobox container"
    }
    if not (has-cmd docker) {
        die "This script requires docker"
    }

    base-mainstall
    sudo apt purge -y fzf
    si openssh-server micro
    ssh-enable
    docker-confstall
}

# Distrobox slim mainstall
export def dt-slim-mainstall []: nothing -> nothing {
    base-mainstall
    enable-ssh-service
}

# Distrobox dev mainstall
export def dt-dev-mainstall []: nothing -> nothing {
    shell-slim-mainstall
    vscode-groupstall

    si firefox gnome-keyring wl-clipboard libsecret
    gnome-keyring-daemon -s -d --components=pkcs11,secrets,ssh
    systemctl --user enable --now dbus
}

# Distrobox dev exports
export def dt-dev-exports []: nothing -> nothing {
    distrobox-export --bin (which stow)
    distrobox-export --bin (which code)
    distrobox-export --app "Visual Studio Code"
}

# Distrobox dev-atomic mainstall
export def dt-dev-atomic-mainstall []: nothing -> nothing {
    dt-dev-mainstall
    dt-dev-exports
}

# NixOS mainstall
export def nixos-mainstall []: nothing -> nothing {
    if not (has-cmd nixos-rebuild) {
        die "Only nixos(linux) supported. Quitting."
    }
    if not (has-cmd nix) {
        die "nix not found, Qutting."
    }

    info "This should only be executed on a freshly installed nixos."
    sleep 5sec

    let config_dir = "~/nix-config"
    if (dir-exists $config_dir) {
        die $"($config_dir) already exists. Quitting."
    }

    slog "Copying /etc/nixos to ($config_dir)..."
    if not (cp -r /etc/nixos $config_dir) {
        die "Failed to copy /etc/nixos"
    }

    let config_src = $env.DOT_DIR | path join "extras" "nixos" "vm"

    slog $"Copying config to ($config_dir)..."
    if not (cp ($config_src | path join "dev.nix") ($config_src | path join "flake.nix") ($config_src | path join "home.nix") $"($config_dir)/") {
        die "Failed to copy config files"
    }

    # Check and replace placeholders
    let flake_content = open ($config_dir | path join "flake.nix")
    if not ($flake_content | str contains "<YOUR_USER_NAME>") {
        die "flake.nix doesn't contain expected <YOUR_USER_NAME> placeholder"
    }

    let home_content = open ($config_dir | path join "home.nix")
    if not ($home_content | str contains "<YOUR_USER_NAME>") {
        die "home.nix doesn't contain expected <YOUR_USER_NAME> placeholder"
    }
    if not ($home_content | str contains "<YOUR_HOME_DIRECTORY>") {
        die "home.nix doesn't contain expected <YOUR_HOME_DIRECTORY> placeholder"
    }

    slog "Ensuring dev.nix is imported..."
    let cfg_file = $config_dir | path join "configuration.nix"
    if not ($cfg_file | path exists) {
        die "configuration.nix not found"
    }

    let cfg_content = open $cfg_file
    if not ($cfg_content | str contains "./dev.nix") {
        # Add dev.nix import
        let new_content = $cfg_content | str replace './hardware-configuration.nix' './hardware-configuration.nix\n    ./dev.nix'
        $new_content | save -f $cfg_file
    }

    slog "Replacing placeholders in flake.nix..."
    sed -i $"s/<YOUR_USER_NAME>/($env.USER)/g" ($config_dir | path join "flake.nix")

    slog "Replacing placeholders in home.nix..."
    sed -i $"s/<YOUR_USER_NAME>/($env.USER)/g" ($config_dir | path join "home.nix")
    sed -i $"s|<YOUR_HOME_DIRECTORY>|($env.HOME)|g" ($config_dir | path join "home.nix")

    let hostname = (get-hostname)
    let flake_content = open ($config_dir | path join "flake.nix")
    if not ($flake_content | str contains $hostname) {
        die $"Hostname '($hostname)' not found in flake.nix. Please add it to the nixosConfigurations."
    }

    slog "Rebuilding system with flake..."
    if not (sudo nixos-rebuild switch --flake $"($config_dir)#($hostname)") {
        fail "nixos-rebuild failed"
    }

    if (has-cmd code) {
        vscode-confstall
    }

    cmd-check nixfmt nixd git zsh devbox devenv docker distrobox nvim shellcheck \
        shfmt stow trash tmux eza gcc make gh ghostty rg tldr code
}

# NixOS WSL mainstall
export def nixos-wsl-mainstall []: nothing -> nothing {
    let config_dir = ~/nix-config

    if (dir-exists $config_dir) {
        die "nix-config already exists, skipping nixos installation"
    }

    nix-dotfiles-install

    slog $"Copying nixos-wsl config to ($config_dir)..."
    if not (cp -r ($env.DOT_DIR | path join "extras" "nixos-wsl" "nixos") $config_dir) {
        die "Failed to copy nixos-wsl config"
    }

    slog "Copying nix.conf to ~/.config..."
    if not (cp -r ($env.DOT_DIR | path join "extras" "nixos-wsl" "nix") ~/.config) {
        die "Failed to copy nix.conf"
    }

    slog "Rebuilding system with flake..."
    let hostname = (get-hostname)
    if not (sudo nixos-rebuild switch --flake $"($config_dir)#($hostname)") {
        die "nixos-rebuild failed"
    }

    slog "nixos-wsl installation done!"
    slog "If anything goes wrong, rollback with:"
    slog "sudo nixos-rebuild switch --rollback"
    slog $"Your configuration is at ($config_dir)"
    slog "Update your configuration, and run:"
    slog $"sudo nixos-rebuild switch --flake ($config_dir)#($hostname)"
    slog "Commit and push your configuration to keep it safe."
}

# KDE configuration
export def kde-confstall []: nothing -> nothing {
    sudo systemctl enable power-profiles-daemon
    sudo systemctl start power-profiles-daemon

    kwriteconfig6 --file ~/.kxkbrc --group=Layout --key=Options caps:ctrlmodifier
}

# KDE groupstall
export def kde-groupstall []: nothing -> nothing {
    let kde_fn = (scope commands | where name == kde-binstall | is-not-empty)
    if $kde_fn {
        kde-binstall
    }
    terminal-groupstall

    flathub-install
    kde-confstall
    if (has-cmd brew) {
        brew install --cask bluefin-wallpapers-plasma-dynamic
    }
}

# Gnome keybindings installation
export def gnome-keybindings-install []: nothing -> nothing {
    gsettings set org.gnome.desktop.wm.keybindings begin-resize "['<Super>BackSpace']"

    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "[]"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "[]"

    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "['<Control><Super>Left']"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "['<Control><Super>Right']"

    gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-left "['<Control><Super><Shift>Left']"
    gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-right "['<Control><Super><Shift>Right']"
}

# Incus groupstall
export def incus-groupstall []: nothing -> nothing {
    let incus_fn = (scope commands | where name == incus-install | is-not-empty)
    if $incus_fn {
        incus-install
    }
}
