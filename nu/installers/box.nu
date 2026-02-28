#! /usr/bin/env nu

# Distrobox/WSL container installer functions

use ../share/utils.nu *
use common.nu *

# Neovim boxstall
export def nvim-boxstall []: nothing -> nothing {
    astrovim-confstall

    if (has-cmd brew) {
        bis luarocks lazygit tectonic fd gdu fzf
        if not (has-cmd nvim) { bi neovim }
        if not (has-cmd tree-sitter) { bi tree-sitter-cli }
        if not (has-cmd rg) { bi ripgrep }
        if not (has-cmd btm) { bi bottom }
    }

    if not (has-cmd pixi) {
        pixi-install
    }

    if (has-cmd pixi) {
        pis nvim luarocks lazygit tectonic gdu fd fzf
        if not (has-cmd tree-sitter) { pi tree-sitter-cli }
        if not (has-cmd rg) { pi ripgrep }
        if not (has-cmd btm) { pi bottom }
    } else {
        # Check for si function
        let si_fn = (scope commands | where name == si | is-not-empty)
        if $si_fn {
            si neovim luarocks lazygit gdu ripgrep bottom btm tree-sitter-cli fd-find fzf

            if (is-apt) {
                warn "Older version of neovim is installed. Some features might not work."
            }
        } else {
            warn "nvim not installed!"
            return
        }
    }

    if not (has-cmd nvim) {
        warn "nvim not installed!"
    }
}

# Emacs version check
export def emacs-version []: nothing -> int {
    (emacs --version | lines | first | split words | get 2 | split row "." | first | into int)
}

# Emacs boxstall
export def emacs-boxstall []: nothing -> nothing {
    srm ~/.emacs
    srm ~/.emacs.d
    ln -s ($env.DOT_DIR | path join "emacs-slim" "dot-emacs") ~/.emacs

    if (has-cmd emacs) and ((emacs-version) > 29) {
        return
    }

    if (has-cmd brew) {
        bi emacs
    } else if (has-cmd pixi) {
        pi emacs
    } else {
        let si_fn = (scope commands | where name == si | is-not-empty)
        if $si_fn {
            si emacs-nox
            if not (has-cmd emacs) {
                si emacs
            }
        }
    }

    if not (has-cmd emacs) {
        warn "emacs not installed! Qutting."
    }
}

# Tmux boxstall
export def tmux-boxstall []: nothing -> nothing {
    srm ~/.config/tmux
    smd ~/.config/tmux
    smd ~/.tmux
    ln -s ($env.DOT_DIR | path join "tmux" "dot-config" "tmux" "tmux.conf") ~/.config/tmux/tmux.conf

    if (has-cmd tmux) {
        return
    }

    if (has-cmd brew) {
        bi tmux
    } else {
        let si_fn = (scope commands | where name == si | is-not-empty)
        if $si_fn {
            si tmux
        }
        if not (has-cmd tmux) and (has-cmd pixi) {
            pi tmux
        }
    }

    if not (has-cmd tmux) {
        warn "tmux not installed! Qutting."
    }
}

# Zsh boxstall
export def zsh-boxstall []: nothing -> nothing {
    srm ~/.zshrc
    ln -s ($env.DOT_DIR | path join "zsh" "dot-zshrc") ~/.zshrc

    if (has-cmd zsh) {
        return
    }

    let si_fn = (scope commands | where name == si | is-not-empty)
    if $si_fn {
        si zsh
    }
    if not (has-cmd zsh) and (has-cmd pixi) {
        pi zsh
    }

    if not (has-cmd zsh) {
        warn "zsh not installed! Qutting."
    }
    set-zsh-as-default
}

# Slimbox base
export def slimbox-base [os_type: string]: nothing -> nothing {
    cd ~

    # Call packages function based on OS type
    let pkg_fn = $"($os_type)-packages"
    let fn_exists = (scope commands | where name == $pkg_fn | is-not-empty)
    if $fn_exists {
        run-external $pkg_fn
    }

    dotfiles-install
    bash-confstall
    starship-install

    if not (dir-exists $env.DOT_DIR) {
        die $"($env.DOT_DIR) doesn't exist, Installation failed."
    }
}

# Box base
export def box-base [os_type: string]: nothing -> nothing {
    slimbox-base $os_type
    zsh-boxstall
}

# Distrobox base
export def dt-base [os_type: string]: nothing -> nothing {
    if not (is-distrobox) {
        die "This script is only for distrobox containers"
    }
    if not ($env.HOME | str contains "boxes") {
        die "This script is only for distrobox containers with isolated home directory"
    }

    box-base $os_type
}

# Get box OS type
export def get-boxos []: nothing -> string {
    if (is-tw) {
        "tw"
    } else if (is-ubuntu) {
        "ubuntu"
    } else if (is-debian) {
        "debian"
    } else if (is-fedora) {
        "fedora"
    } else if (is-arch) {
        "arch"
    } else if (is-centos) {
        "centos"
    } else if (is-alpine) {
        "alpine"
    } else {
        "brew"
    }
}

# Slimbox mainstall
export def slimbox-mainstall []: nothing -> nothing {
    slimbox-base (get-boxos)
}

# Box mainstall
export def box-mainstall []: nothing -> nothing {
    box-base (get-boxos)
}

# Fullbox mainstall
export def fullbox-mainstall []: nothing -> nothing {
    box-base (get-boxos)
    nvim-boxstall
    tmux-boxstall
    emacs-boxstall
}

# Distrobox mainstall
export def dt-mainstall []: nothing -> nothing {
    dt-base (get-boxos)
    enable-ssh-service
}

# DBox mainstall (alias)
export def dbox-mainstall []: nothing -> nothing {
    dt-mainstall
}

# TW WSL box mainstall
export def tw-wslbox-mainstall []: nothing -> nothing {
    if not (is-tw) {
        die "This script is only for openSUSE Tumbleweed"
    }

    sudo systemd-tmpfiles --create
    wslbox-base "tw"
}

# WSL box mainstall
export def wslbox-mainstall []: nothing -> nothing {
    if (is-tw) {
        tw-wslbox-mainstall
    } else {
        box-base (get-boxos)
    }
}

# WSL mainstall
export def wsl-mainstall []: nothing -> nothing {
    wslbox-mainstall
    brew-install
    bis stow carapace fzf trash-cli lazygit eza zoxide gh gum
    if not (has-cmd delta) {
        bi git-delta
    }

    zsh-boxstall
}

# CentOS WSL mainstall
export def centos-wsl-mainstall []: nothing -> nothing {
    wsl-mainstall

    tmux-boxstall
    nvim-boxstall
}

# CentOS fast mainstall
export def centos-fast-mainstall []: nothing -> nothing {
    if not (is-centos) {
        die "This script is only for CentOS"
    }

    sudo dnf update
    sudo dnf install -y git-core wget curl gcc make unzip tar tree neovim tmux \
        zsh gcc-c++ gdb clang lldb lld llvm bat gum ripgrep luarocks

    pixi-install
    pixi global install trash-cli fzf lazygit eza zoxide gh git-delta

    starship-install
    tmux-boxstall
    nvim-boxstall
    zsh-boxstall
}

# WSL box base (placeholder)
export def wslbox-base [os_type: string]: nothing -> nothing {
    box-base $os_type
}
