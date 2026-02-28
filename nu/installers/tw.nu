#! /usr/bin/env nu

# openSUSE Tumbleweed (Zypper) installer functions

use ../share/utils.nu *
use common.nu *

# zypper install helper (non-interactive)
export def zi [...packages: string]: nothing -> nothing {
    sudo zypper --non-interactive --quiet install --auto-agree-with-licenses ...$packages
}

# Main package install function
export def si [...packages: string]: nothing -> nothing {
    # Try batch install first
    let result = (try { zi ...packages | complete | get exit_code | $in == 0 } catch { false })
    if $result {
        return
    }

    # Fallback to individual installs
    for p in $packages {
        slog $"Installing package ($p)"
        zi $p
    }
}

# Update packages
export def update-packages []: nothing -> nothing {
    slog "Updating SUSE"

    if not ({ sudo zypper refresh && sudo zypper --non-interactive --quiet dup } | complete | get exit_code | $in == 0) {
        die "zypper refresh failed. quitting"
    }
}

# Tumbleweed packages installation
export def tw-packages []: nothing -> nothing {
    update-packages

    slog "Installing packages"

    si git gh git-delta unzip wget curl trash-cli tar stow gcc make file \
        starship gum wl-clipboard tree bat eza fzf ripgrep zoxide fd \
        htop sd tealdeer yazi cheat lazygit libsecret net-tools iproute2 nmap \
        dialog newt python314 python314-pip python314-pipx osinfo-db-tools

    if (has-cmd tldr) {
        tldr --update
    }

    slog "Installing packages done!"
}

# System Python installation
export def system-python-install []: nothing -> nothing {
    slog "Installing python"

    si python314 python314-virtualenv python314-pip python314-setuptools \
        python314-pipx
    pipx install uv

    slog "Python installation done!"
}

# Locale setup
export def locale-setup []: nothing -> nothing {
    let locale = "en_US.UTF-8"
    let keymap = "us"

    sudo localectl set-locale LANG=$locale

    sudo localectl set-keymap $keymap
    sudo localectl set-x11-keymap $keymap

    echo $"KEYMAP=($keymap)" | sudo tee /etc/vconsole.conf | ignore
    echo $"LANG=($locale)" | sudo tee /etc/locale.conf | ignore

    sudo loadkeys $keymap
}

# Core installation
export def core-install []: nothing -> nothing {
    update-packages

    slog "Installing core packages"

    si curl wget git tar tree unzip stow file trash-cli which

    slog "Core packages installation done!"
}

# Snap installation
export def snap-install []: nothing -> nothing {
    if (has-cmd snap) {
        return
    }

    slog "Installing snap..."

    sudo zypper addrepo --refresh https://download.opensuse.org/repositories/system:/snappy/openSUSE_Tumbleweed snappy
    sudo zypper --gpg-auto-import-keys refresh
    sudo zypper dup --from snappy
    sudo systemctl enable --now snapd

    slog "snap installation done!"
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

# Essential installation
export def essential-install []: nothing -> nothing {
    pkgx-install

    slog "Installing essential packages"

    sudo zypper install -y -t pattern devel_basis

    si unar zip micro-editor 7zip readline-devel sqlite3-devel libffi-devel \
        libbz2-devel xz-devel gum libsecret gawk newt

    slog "Essential packages installation done!"
}

# CLI slim installation
export def cli-slim-install []: nothing -> nothing {
    slog "Installing cli tools using zypper"

    si zsh git starship ripgrep gh fzf zoxide eza

    slog "cli tools installation done!"
}

# CLI installation
export def cli-install []: nothing -> nothing {
    slog "Installing cli tools using zypper"

    cli-slim-install

    si neovim sd fd procs lazygit bottom xh plocate tealdeer urlview nushell \
        lua54-luarocks python3-neovim ImageMagick gdu duf ugrep yazi dysk jq jc \
        hyperfine cheat curlie lsd direnv yq tmux htop fd bat git-delta dust \
        shfmt ShellCheck just dialog atuin broot choose fastfetch

    if (has-cmd tldr) {
        tldr --update
    }

    system-python-install

    slog "cli tools installation done!"
}

# C++ installation
export def cpp-install []: nothing -> nothing {
    slog "Installing C++"

    si gcc gdb g++ boost-devel catch2-devel ltrace strace lldb lld \
        clang llvm clang-tools clang-devel valgrind systemtap \
        doxygen graphviz ccache cppcheck python3-pre-commit cmake

    conan-install

    slog "C++ installation done!"
}

# VSCode binary installation
export def vscode-binstall []: nothing -> nothing {
    if (has-cmd code) {
        return
    }

    slog "Installing vscode"

    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    let repo_content = "[code]
name=Visual Studio Code:
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
type=rpm-md
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc"

    $repo_content | sudo tee /etc/zypp/repos.d/vscode.repo | ignore
    sudo zypper refresh
    si code

    slog "vscode installation done!"

    cmd-check code
}

# Terminal binary installation
export def terminal-binstall []: nothing -> nothing {
    if (has-cmd ghostty) {
        return
    }

    slog "Installing ghostty"
    si ghostty
    slog "ghostty installation done!"
}

# VM UI installation
export def vm-ui-install []: nothing -> nothing {
    if not (is-desktop) {
        return
    }

    slog "Installing virt ui packages"

    si gnome-boxes
    if (has-cmd virt-install) {
        si virt-manager virt-viewer
    }

    slog "virt ui packages installation done!"
}

# Cockpit installation
export def cockpit-install []: nothing -> nothing {
    if (has-cmd cockpit) {
        return
    }

    slog "Installing cockpit"

    si systemd-networkd cockpit cockpit-machines cockpit-pcp cockpit-podman \
        cockpit-storaged cockpit-kdump cockpit-networkmanager \
        cockpit-packagekit cockpit-system cockpit-tukit
    sudo systemctl enable --now cockpit.socket

    slog "cockpit installation done!"
}

# VM installation
export def vm-install []: nothing -> nothing {
    slog "Installing libvirt"

    si libvirt qemu-kvm virt-install bridge-utils qemu-img qemu-ui-spice-core \
        qemu-ui-spice-app qemu-char-spice qemu-audio-spice jq jc xmlstarlet \
        qemu-hw-display-virtio-gpu qemu-hw-display-virtio-vga qemu-hw-usb-host \
        qemu-hw-usb-redirect qemu-ovmf-x86_64 qemu-tools qemu-ui-gtk \
        qemu-ui-opengl libguestfs guestfs-tools libosinfo openssl

    slog "libvirt installation done!"
}

# Docker installation
export def docker-install []: nothing -> nothing {
    if (has-cmd docker) {
        return
    }

    slog "Installing docker"

    si docker docker-compose docker-compose-switch dive slim

    slog "docker installation done!"
}

# Incus installation
export def incus-install []: nothing -> nothing {
    if (has-cmd incus) {
        return
    }

    slog "Installing incus"

    si incus qemu-kvm qemu-tools bridge-utils openssl
    incus-confstall

    slog "incus installation done!"
}

# Distrobox installation
export def distrobox-install []: nothing -> nothing {
    if (has-cmd distrobox) {
        return
    }

    slog "Installing distrobox"
    si buildah distrobox podman podman-remote
    slog "distrobox installation done!"
}

# Desktop core installation
export def desktop-core-install []: nothing -> nothing {
    sin kitty wl-clipboard gnome-keyring libsecret-tools \
        papirus-icon-theme udisks2 udiskie gvfs flatpak imagemagick

    flathub-install
    fpi app.zen_browser.zen

    jetbrains-mono-install
    font-awesome-install
    wallpapers-install
}

# WM tools installation
export def wm-tools-install []: nothing -> nothing {
    sin aaa_base bash-completion pipewire imv xdg-utils sudo gzip bzip2 jc \
        adwaita-icon-theme clipman bluez qt5ct qt6ct grim cliphist mpv \
        dejavu-fonts glibc-locale less google-roboto-fonts ghostscript-fonts-std \
        noto-sans-fonts google-droid-fonts google-opensans-fonts playerctl pamixer \
        gtk3-metatheme-adwaita noto-coloremoji-fonts noto-emoji-fonts mpris-ctl \
        adobe-sourcecodepro-fonts command-not-found metatheme-adwaita-common slurp \
        bluemoon symbols-only-nerd-fonts adobe-sourcesanspro-fonts brightnessctl \
        adobe-sourceserifpro-fonts cantarell-fonts tlp google-carlito-fonts \
        ghostscript-fonts-other
}

# WM installation
export def wm-install []: nothing -> nothing {
    desktop-core-install
    wm-tools-install

    sin xdg-desktop-portal xdg-desktop-portal-wlr adwaita-icon-theme clipman \
        bluez qt5ct qt6ct grim cliphist mpv playerctl pamixer mpris-ctl slurp \
        bluemoon symbols-only-nerd-fonts adobe-sourcesanspro-fonts brightnessctl \
        nwg-displays nwg-look inter-fonts nvtop
}

# sin helper
export def sin [...packages: string]: nothing -> nothing {
    sudo zypper install -y --no-recommends ...$packages
}

# Sway binary installation
export def sway-binstall []: nothing -> nothing {
    slog "Installing sway"

    sudo zypper install -y -t pattern openSUSEway

    wm-install

    sin swaylock swaybg swayidle swaynag waybar rofi-wayland polkit-kde-agent-6 \
        SwayNotificationCenter SwayNotificationCenter-bash-completion sway-marker \
        SwayNotificationCenter-zsh-completion xdg-desktop-portal-gtk greetds

    slog "sway installation done!"
}

# Hyprland installation
export def hyprland-install []: nothing -> nothing {
    slog "Installing hyprland"

    wm-install

    sin NetworkManager hyprcursor hypridle hyprland hyprland-bash-completion \
        hyprland-devel hyprlock hyprland-wallpapers hyprland-zsh-completion \
        hyprpaper hyprpicker hyprpolkitagent hyprshot xdg-desktop-portal-hyprland \
        hyprland-qt-support hyprland-qtutils qt6ct waybar rofi-wayland

    cmd-check hyprcursor hypridle hyprctl hyprlock hyprpicker
    cmd-check pactl waybar clipman imv mpv hyprshot ghostty
    cmd-check brightnessctl pamixer playerctl greetd
    cmd-check bluetoothctl bluemoon tlp firefox slurp qt5ct
    cmd-check swaync swaync-client

    slog "hyprland installation done!"
}

# PM installation
export def pm-install []: nothing -> nothing {
    si net-tools iproute2 nmap sensors stress-ng taliscale wireguard-tools \
        smartmontools memtest86+ glmark2
}

# KDE slim binary installation
export def kde-slim-binstall []: nothing -> nothing {
    slog "Installing minimal kde plasma..."

    desktop-core-install

    sin plasma6-desktop systemsettings6 kscreen6 kio-extras powerdevil6 \
        power-profiles-daemon wl-clipboard
    slog "kde plasma installation done!"
}

# KDE binary installation
export def kde-binstall []: nothing -> nothing {
    kde-slim-binstall

    sin discover6 discover6-backend-flatpak discover6-backend-packagekit
}
