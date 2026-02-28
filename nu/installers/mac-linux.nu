#! /usr/bin/env nu

# macOS and Linux shared installer functions

use ../share/utils.nu *
use common.nu *

# Nix installation
export def nix-install []: nothing -> nothing {
    if (has-cmd nix) {
        return
    }

    slog "Installing nix"
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --determinate --no-confirm

    source-if-exists /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

    slog "nix installation done!"

    cmd-check nix nix-shell nix-env
}

# Base config install
export def base-config-install []: nothing -> nothing {
    dotfiles-install
    if (has-cmd git) { git-confstall }
    if (is-linux) { bash-confstall }
    if (is-mac) { zsh-confstall }
}

# Min config install
export def min-config-install []: nothing -> nothing {
    base-config-install
}

# Shell-slim config install
export def shell-slim-config-install []: nothing -> nothing {
    min-config-install
    zsh-confstall
}

# Shell config install
export def shell-config-install []: nothing -> nothing {
    shell-slim-config-install
    tmux-confstall
    nvim-confstall astro
    yazi-confstall
}

# Groupstall helper
export def groupstall [name: string]: nothing -> nothing {
    let fn_name = $"($name)-groupstall"
    let fn_exists = (scope commands | where name == $fn_name | is-not-empty)
    if $fn_exists {
        run-external $fn_name
    }
}

# Mainstall helper
export def mainstall [name: string]: nothing -> nothing {
    let fn_name = $"($name)-mainstall"
    let fn_exists = (scope commands | where name == $fn_name | is-not-empty)
    if $fn_exists {
        run-external $fn_name
    }
}

# Base binstall
export def base-binstall []: nothing -> nothing {
    let core_fn = (scope commands | where name == core-install | is-not-empty)
    if $core_fn {
        core-install
    } else {
        warn "core-install not available, skipping core installation"
    }
}

# Bash config check
export def bash-config-check []: nothing -> nothing {
    if not (bash-config-exists) {
        warn "bash config is not setup correctly"
    }
}

# Base check
export def base-check []: nothing -> nothing {
    cmd-check curl wget git trash stow tree tar unzip
    dir-check $env.DOT_DIR
    bash-config-check
}

# DF confstall
export def df-confstall []: nothing -> nothing {
    slog "Configuring bash"

    let bashrc = ~/.bashrc | path expand
    let has_config = if ($bashrc | path exists) {
        let content = open $bashrc
        ($content | str contains ".ilm/share/shellrc") or ($content | str contains "source ${DOT_DIR}/share/shellrc")
    } else {
        false
    }

    if not $has_config {
        echo $"export DOT_DIR=($env.DOT_DIR)" >> ~/.bashrc
        echo 'source ${DOT_DIR}/share/shellrc' >> ~/.bashrc
    }

    slog "bash config done!"
}

# DF mainstall
export def df-mainstall []: nothing -> nothing {
    base-binstall
    dotfiles-install
    df-confstall
}

# Base mainstall
export def base-mainstall []: nothing -> nothing {
    base-binstall
    base-config-install
    base-check

    let key = (ssh-key-path)
    if ($key | is-not-empty) {
        slog $"SSH key at: ($key)"
    } else {
        warn "Could not generate ssh key"
    }
}

# Min binstall
export def min-binstall []: nothing -> nothing {
    base-binstall
    let essential_fn = (scope commands | where name == essential-install | is-not-empty)
    if $essential_fn {
        essential-install
    } else {
        warn "essential-install not available, skipping essential installation"
    }

    if (is-distrobox) {
        return
    }

    let ui_fn = (scope commands | where name == ui-install | is-not-empty)
    if $ui_fn {
        ui-install
    }
}

# Shell-slim binstall
export def shell-slim-binstall []: nothing -> nothing {
    let cli_fn = (scope commands | where name == cli-slim-install | is-not-empty)
    if $cli_fn {
        cli-slim-install
    } else {
        warn "cli-slim-install not available, skipping cli installation"
    }
    shell-slim-install
}

# Shell binstall
export def shell-binstall []: nothing -> nothing {
    let cli_fn = (scope commands | where name == cli-install | is-not-empty)
    if $cli_fn {
        cli-install
    } else {
        warn "cli-install not available, skipping cli installation"
    }

    if not (is-distrobox) {
        terminal-groupstall
    }

    shell-install
    brew-install
}

# Shell-slim groupstall
export def shell-slim-groupstall []: nothing -> nothing {
    shell-slim-binstall
    shell-slim-config-install
}

# Terminal config install
export def terminal-config-install []: nothing -> nothing {
    alacritty-confstall
    kitty-confstall
    ghostty-confstall
    wezterm-confstall
}

# Terminal groupstall
export def terminal-groupstall []: nothing -> nothing {
    if not (is-desktop) {
        warn "Not running desktop, skipping terminal installation"
        return
    }

    jetbrains-mono-install
    terminal-binstall
    terminal-config-install

    if (is-linux) {
        ptyxis-install
    }
}

# Shell groupstall
export def shell-groupstall []: nothing -> nothing {
    shell-binstall
    if not (is-distrobox) {
        terminal-groupstall
    }
    shell-config-install
    brew-install
}

# Brew groupstall
export def brew-groupstall []: nothing -> nothing {
    brew-install
    brew-shell-install
}

# Home-manager installation
export def home-manager-install []: nothing -> nothing {
    if not (has-cmd nix) {
        warn "nix not installed, skipping home-manager installation"
        return
    }

    if (dir-exists ~/nix-config) {
        slog "$HOME/nix-config exists, skipping home-manager installation"
        return
    }

    let hm_dir = $env.DOT_DIR | path join "extras" "home-manager"
    if not (dir-exists $hm_dir) {
        nix-dotfiles-install
    }

    if not (dir-exists $hm_dir) {
        warn "could not setup dotfiles, cannot install home-manager."
        return
    }

    if not (cp -r $hm_dir ~/nix-config) {
        warn "Failed to copy home-manager config to $HOME/nix-config"
        return
    }

    # nix-vars-create would be called here

    slog "nix-config copied to ~/nix-config. Running hms to apply configuration."

    hms
}

# Nix groupstall
export def nix-groupstall []: nothing -> nothing {
    nix-install
    home-manager-install
}

# Nix check
export def nix-check []: nothing -> nothing {
    min-check
    cmd-check home-manager nix devbox
}

# Nix mainstall
export def nix-mainstall []: nothing -> nothing {
    min-mainstall
    let si_fn = (scope commands | where name == si | is-not-empty)
    if $si_fn and not (has-cmd zsh) {
        si zsh
    }
    nix-groupstall
    nix-check
}

# Docker groupstall
export def docker-groupstall []: nothing -> nothing {
    docker-install

    if not (is-linux) {
        return
    }
    if not (is-distrobox) {
        fpi sh.loft.devpod
    }
    docker-confstall
    lazydocker-install
}

# Work groupstall
export def work-groupstall []: nothing -> nothing {
    shell-slim-groupstall
    vscode-groupstall
    docker-groupstall
}

# VM groupstall
export def vm-groupstall []: nothing -> nothing {
    let vm_fn = (scope commands | where name == vm-install | is-not-empty)
    if $vm_fn {
        vm-install
    } else {
        warn "vm-install not available, skipping vm installation"
        return
    }

    if not (is-distrobox) {
        let vm_ui_fn = (scope commands | where name == vm-ui-install | is-not-empty)
        if $vm_ui_fn {
            vm-ui-install
        }
    }

    if not (is-linux) {
        return
    }

    cockpit-install
    libvirt-confstall
    if (has-cmd osinfo-db-import) {
        sudo osinfo-db-import --system --latest
    }
}

# Min check
export def min-check []: nothing -> nothing {
    base-check
    cmd-check micro zip gcc make whiptail
}

# Min mainstall
export def min-mainstall []: nothing -> nothing {
    min-binstall
    min-config-install
    min-check
}

# Shell-slim check
export def shell-slim-check []: nothing -> nothing {
    min-check
    cmd-check zsh rg starship zoxide eza gh fzf
}

# Shell-slim mainstall
export def shell-slim-mainstall []: nothing -> nothing {
    min-binstall
    shell-slim-binstall
    shell-slim-config-install
    shell-slim-check
}

# Shell check
export def shell-check []: nothing -> nothing {
    shell-slim-check
    cmd-check tmux nvim lazygit sd bat htop atuin gawk carapace direnv \
        shellcheck shfmt ug tldr direnv jq yq gum bat delta just dialog \
        btm yazi

    if not (has-cmd fd) and not (has-cmd fdfind) {
        warn "fd or fdfind not found"
    }
}

# Shell mainstall
export def shell-mainstall []: nothing -> nothing {
    min-binstall
    shell-binstall
    shell-config-install
    terminal-config-install
    shell-check
}

# VM check
export def vm-check []: nothing -> nothing {
    min-check

    if (is-linux) {
        cmd-check virt-install virt-xml virsh jq virt-cat qemu-img wget xorriso
        if (is-desktop) {
            cmd-check virt-viewer virt-manager
        }
    } else if (is-mac) {
        cmd-check jq colima orbstack
    }
}

# VM mainstall
export def vm-mainstall []: nothing -> nothing {
    min-mainstall
    vm-groupstall
    vm-check
}

# Work check
export def work-check []: nothing -> nothing {
    shell-slim-check
    cmd-check code docker
}

# Work mainstall
export def work-mainstall []: nothing -> nothing {
    min-mainstall
    work-groupstall
    apps-slim-install
    work-check
}

# Desktop-slim mainstall
export def desktop-slim-mainstall []: nothing -> nothing {
    shell-slim-mainstall
    vm-groupstall
    vscode-groupstall

    apps-slim-install

    vm-check
    work-check
}

# Desktop mainstall
export def desktop-mainstall []: nothing -> nothing {
    shell-mainstall
    vm-groupstall
    vscode-groupstall

    apps-install

    vm-check
    work-check
}

# VSCode groupstall
export def vscode-groupstall []: nothing -> nothing {
    # OS-specific vscode_binstall would be called here
    let vscode_fn = (scope commands | where name == vscode-binstall | is-not-empty)
    if $vscode_fn {
        vscode-binstall
    }
    jetbrains-mono-install
    vscode-confstall
}

# Nix dotfiles install
export def nix-dotfiles-install []: nothing -> nothing {
    # Clone/copy nix dotfiles
    slog "Nix dotfiles install placeholder"
}
