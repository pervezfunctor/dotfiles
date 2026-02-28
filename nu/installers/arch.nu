#! /usr/bin/env nu

# Arch Linux (Pacman) installer functions

use ../share/utils.nu *
use common.nu *

# Main package install function
export def si [...packages: string]: nothing -> nothing {
    sudo pacman -S --quiet --noconfirm ...$packages
}

# Update packages
export def update-packages []: nothing -> nothing {
    slog "Updating Arch"

    if not (sudo pacman -Syu --noconfirm --quiet | complete | get exit_code | $in == 0) {
        die "pacman update/upgrade failed, quitting"
    }
}

# AUR helper function
export def aur [...packages: string]: nothing -> nothing {
    if not (has-cmd paru) and not (has-cmd yay) {
        paru-install
    }

    if (has-cmd paru) {
        paru -S --noconfirm ...$packages
    } else if (has-cmd yay) {
        yay -S --noconfirm ...$packages
    } else {
        die "paru or yay not installed, cannot install AUR packages"
    }
}

# Arch packages installation
export def arch-packages []: nothing -> nothing {
    update-packages

    slog "Installing packages"

    si bat bottom choose curl dialog direnv dust dysk eza fd file fzf gcc git \
        git-delta github-cli gum htop iproute2 jq just lazygit libnewt libsecret \
        make micro net-tools nmap pixi procs python python-pip python-pipx jc \
        python-uv ripgrep sd shellcheck shfmt starship stow tar tealdeer fastfetch \
        trash-cli tree ugrep unzip wget which wl-clipboard xh yazi yq zoxide

    if (has-cmd tldr) {
        tldr --update
    }

    slog "Installing packages done!"
}

# Locale setup
export def locale-setup []: nothing -> nothing {
    let locale = "en_US.UTF-8"
    let keymap = "us"

    slog "Configuring locale and keyboard for Arch Linux..."

    sudo sed -i $"s/^# *($locale)/($locale)/" /etc/locale.gen
    sudo locale-gen
    echo $"LANG=($locale)" | sudo tee /etc/locale.conf | ignore

    echo $"KEYMAP=($keymap)" | sudo tee /etc/vconsole.conf | ignore
    sudo loadkeys $keymap
}

# Core installation
export def core-install []: nothing -> nothing {
    update-packages

    slog "Installing core packages"

    si curl wget git trash-cli tree tar unzip stow zstd file reflector

    slog "Core packages installation done!"
}

# System Python installation
export def system-python-install []: nothing -> nothing {
    slog "Installing python"

    si python python-pipx python-pip python-setuptools python-wheel \
        python-virtualenv
    pipx install uv

    slog "Python installation done!"
}

# Paru installation
export def paru-install []: nothing -> nothing {
    if (has-cmd paru) or (has-cmd yay) {
        return
    }

    slog "Installing paru"

    frm /tmp/paru
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    cd /tmp/paru
    makepkg --syncdeps --noconfirm --install
    cd -
    frm /tmp/paru

    slog "paru installation done!"
}

# Snap installation
export def snap-install []: nothing -> nothing {
    aur snapd
    sudo systemctl enable --now snapd
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
    slog "Installing essential packages"

    pkgx-install

    si unarchiver zip tmux pkg-config fuse2 p7zip xz readline micro libnewt \
        sqlite libffi zlib pkgfile libxcrypt-compat libsecret gawk base-devel

    sudo pkgfile --update
    sudo pacman -Fy

    slog "Essential packages installation done!"
}

# CLI slim installation
export def cli-slim-install []: nothing -> nothing {
    slog "Installing cli tools using pacman"

    si zsh github-cli fzf ripgrep zoxide eza starship

    slog "cli tools installation done!"
}

# CLI installation
export def cli-install []: nothing -> nothing {
    slog "Installing cli tools using pacman"

    cli-slim-install

    si neovim tmux shellcheck shfmt python-pynvim zsh-completions bat jq yq \
        luarocks duf lazygit ugrep git-delta navi sd gdu hyperfine fd lsd xh \
        htop nushell bottom plocate tealdeer television dysk yazi procs jc \
        dust direnv atuin broot glances curlie superfile choose just dialog \
        gum lazydocker

    if (has-cmd tldr) {
        tldr --update
    }

    system-python-install

    slog "cli tools installation done!"
}

# C++ installation
export def cpp-install []: nothing -> nothing {
    slog "Installing C++"

    si gcc gdb boost boost-libs catch2 libc++ clang llvm \
        doxygen graphviz ccache cppcheck pre-commit \
        valgrind ltrace strace lldb lld cmake

    conan-install

    slog "C++ installation done!"

    cmd-check gcc gdb make cmake conan clang clang++ clang-tidy clang-format
}

# VSCode binary installation
export def vscode-binstall []: nothing -> nothing {
    slog "Installing vscode"

    aur visual-studio-code-bin

    slog "vscode installation done!"

    cmd-check code
}

# Terminal binary installation
export def terminal-binstall []: nothing -> nothing {
    slog "Installing terminal"

    si ghostty

    slog "terminal installation done!"
}

# VM UI installation
export def vm-ui-install []: nothing -> nothing {
    if not (is-desktop) {
        return
    }

    slog "Installing virt ui packages"

    let pkgs = [qemu-desktop]
    let pkgs = if not (has-cmd gnome-boxes) { $pkgs | append gnome-boxes } else { $pkgs }
    let pkgs = if (has-cmd virt-install) { $pkgs | append [virt-manager virt-viewer] } else { $pkgs }

    si ...$pkgs

    slog "virt ui packages installation done!"
}

# Cockpit installation
export def cockpit-install []: nothing -> nothing {
    if (has-cmd cockpit) {
        return
    }

    slog "Installing cockpit"

    si cockpit cockpit-machines cockpit-packagekit cockpit-pcp cockpit-podman \
        cockpit-storaged
    sudo systemctl enable --now cockpit.socket

    slog "cockpit installation done!"
}

# NFTables installation
export def nftables-install []: nothing -> nothing {
    let has_nftables = (try { pacman -Qi nftables | complete | get exit_code | $in == 0 } catch { false })
    if $has_nftables {
        return
    }

    sudo pacman -S --noconfirm --ask=4 iptables-nft nftables
}

# VM installation
export def vm-install []: nothing -> nothing {
    slog "Installing vm"

    nftables-install

    si libvirt qemu-base virt-install bridge-utils dnsmasq libosinfo openssl \
        edk2-ovmf virglrenderer libisoburn cloud-utils dmidecode libguestfs jq \
        guestfs-tools qemu-hw-display-virtio-gpu libosinfo openbsd-netcat jc \
        xmlstarlet ovmf osinfo-db osinfo-db-tools

    slog "vm installation done!"
}

# Docker installation
export def docker-install []: nothing -> nothing {
    if (has-cmd docker) {
        return
    }

    slog "Installing docker"

    si docker docker-compose dive slim

    slog "docker installation done!"
}

# Incus installation
export def incus-install []: nothing -> nothing {
    if (has-cmd incus) {
        return
    }

    slog "Installing incus"

    nftables-install
    si incus qemu-desktop bridge-utils openssl
    incus-confstall

    slog "incus installation done!"
}

# Distrobox installation
export def distrobox-install []: nothing -> nothing {
    if (has-cmd distrobox) {
        return
    }

    slog "Installing distrobox"
    si buildah distrobox podman podman-compose
    slog "distrobox installation done!"
}

# sin helper
export def sin [...packages: string]: nothing -> nothing {
    sudo pacman -S --quiet --noconfirm --needed ...$packages
}

# Firewall setup
export def firewall-setup []: nothing -> nothing {
    si nftables firewalld
    sudo systemctl enable --now firewalld
}

# Desktop core installation
export def desktop-core-install []: nothing -> nothing {
    si flatpak kitty gnome-keyring wl-clipboard libsecret papirus-icon-theme \
        udisks2 udiskie gvfs flatpak qt6-multimedia-gstreamer pipewire-jack \
        ttf-jetbrains-mono-nerd otf-font-awesome imagemagick

    flathub-install
    paru-install
    aur -S bibata-cursor-theme

    fpi app.zen_browser.zen
    wallpapers-install
}

# WM tools installation
export def wm-tools-install []: nothing -> nothing {
    sin waybar rofi mako pavucontrol playerctl wlsunset \
        network-manager-applet nm-connection-editor lxappearance nwg-bar \
        nwg-displays nwg-panel nwg-look greetd

    aur wlogout
}

# WM installation
export def wm-install []: nothing -> nothing {
    desktop-core-install
    wm-tools-install

    sin grim slurp thunar thunar-archive-plugin cliphist xdg-desktop-portal \
        qt5ct qt6ct polkit imv nvtop mpv ttf-roboto noto-fonts noto-fonts-emoji \
        tumbler pipewire pipewire-pulse xdg-desktop-portal-wlr wl-clip-persist \
        pamixer brightnessctl pavucontrol blueman bluez bluez-utils adw-gtk-theme

    aur pywalfox-native pywal matugen-bin bibata-cursor-theme
}

# Hyprland binary installation
export def hyprland-binstall []: nothing -> nothing {
    slog "Installing hyprland packages"

    wm-install

    sin hyprland hyprcursor hypridle hyprshot hyprlock hyprpolkitagent \
        hyprsunset hyprutils hyprwayland-scanner nwg-dock-hyprland hyprpaper \
        xdg-desktop-portal-hyprland hyprland-qt-support

    slog "hyprland installation done!"
}

# Sway binary installation
export def sway-binstall []: nothing -> nothing {
    slog "Installing sway packages"

    wm-install

    sin sway swaybg swayidle swaylock polkit-kde-agent xdg-desktop-portal-gtk

    slog "sway installation done!"
}

# PM installation
export def pm-install []: nothing -> nothing {
    si nmap net-tools iproute2 lm_sensors stress-ng taliscale wireguard-tools \
        smartmontools memtest86+ glmark2
}

# KDE slim binary installation
export def kde-slim-binstall []: nothing -> nothing {
    slog "Installing minimal kde plasma..."

    desktop-core-install

    sin plasma-desktop noto-fonts \
        pipewire-jack systemsettings kscreen kio-extras udisks2 powerdevil \
        power-profiles-daemon qt6-multimedia-gstreamer wl-clipboard

    sin mesa
    slog "kde plasma installation done!"
}

# KDE binary installation
export def kde-binstall []: nothing -> nothing {
    kde-slim-binstall
    sin discover mesa-utils
}

# Mango binary installation
export def mango-binstall []: nothing -> nothing {
    slog "Installing mango packages"
    wm-install

    sin mangowc-git swayidle wlr-randr swayosd satty sox swaybg

    aur sway-audio-idle-inhibit-git swaylock-effects-git dms-shell-git

    slog "mango installation done!"
}

# Niri binary installation
export def niri-binstall []: nothing -> nothing {
    sudo pacman -Syu niri xwayland-satellite xdg-desktop-portal-gnome xdg-desktop-portal-gtk alacritty
    paru -S dms-shell-bin matugen wl-clipboard cliphist cava qt6-multimedia-ffmpeg
    systemctl --user add-wants niri.service dms
}
