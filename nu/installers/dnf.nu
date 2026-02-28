#! /usr/bin/env nu

# Fedora/RHEL (DNF) installer functions

use ../share/utils.nu *
use common.nu *

# Docker Fedora repo setup
export def docker-fedora-repo []: nothing -> nothing {
    if (has-cmd docker) {
        return
    }

    si dnf-plugins-core

    if (is-rocky) {
        sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    }
    if (is-fedora) {
        sudo dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    }
}

# VSCode Fedora repo setup
export def vscode-fedora-repo []: nothing -> nothing {
    if (has-cmd code) {
        return
    }

    let vscode_repo = "/etc/yum.repos.d/vscode.repo"
    if ($vscode_repo | path exists) {
        return
    }

    slog "Adding vscode repo"

    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    let repo_content = "[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc"
    $repo_content | sudo tee $vscode_repo | ignore

    slog "vscode repo added!"
}

# Main package install function
export def si [...packages: string]: nothing -> nothing {
    if (has-cmd dnf5) {
        sudo dnf5 -y \
            --setopt=install_weak_deps=False \
            --setopt=fastestmirror=True \
            --setopt=keepcache=False \
            --setopt=defaultyes=True \
            --setopt=max_parallel_downloads=10 \
            --setopt=metadata_timer_sync=0 \
            install --skip-unavailable --skip-broken ...$packages
    } else {
        slog "Installing packages..."
        for p in $packages {
            sudo dnf -y install $p
        }
        slog "Packages installation done!"
    }
}

# Enable EPEL
export def enable-epel []: nothing -> nothing {
    slog "Enabling EPEL"
    if (is-rocky) or (is-centos) {
        sudo dnf config-manager --set-enabled crb
    }

    if (is-fedora) {
        sudo dnf-3 config-manager --set-enabled crb
    }
    si epel-release
}

# Update packages
export def update-packages []: nothing -> nothing {
    slog "Updating..."
    if not ({ sudo dnf update -y && sudo dnf upgrade -y } | complete | get exit_code | $in == 0) {
        die "dnf update/upgrade failed, quitting"
    }
    slog "Update done!"
}

# Fedora packages installation
export def fedora-packages []: nothing -> nothing {
    update-packages

    slog "Installing packages"

    si git-core gh git-delta unzip wget curl trash-cli tar stow gcc make file \
        gum wl-clipboard tree fzf ripgrep zoxide fd htop bat tealdeer plocate \
        cheat libsecret net-tools iproute nmap dialog newt jq jc procs direnv yq \
        python3 pipx python3-pip

    if (has-cmd tldr) {
        tldr --update
    }

    slog "Installing packages done!"
}

# CentOS packages installation
export def centos-packages []: nothing -> nothing {
    update-packages

    slog "Installing packages"

    si git unzip wget curl tar gcc make gum tree bat ripgrep \
        htop bat plocate file just emacs-nox neovim tmux zsh libsecret \
        net-tools iproute nmap

    slog "Installing packages done!"
}

# Base dev installation
export def base-dev-install []: nothing -> nothing {
    let has_c_dev = (dnf group list -q | grep -q "c-development")
    let has_dev_tools = (dnf group list -q | grep -q "Development Tools")

    if $has_c_dev {
        si "@c-development"
    } else if $has_dev_tools {
        sudo dnf group install --setop=install_weak_deps=False --with-optional -y "Development Tools"
    } else {
        si gcc make cmake autoconf automake binutils expect flex bison glibc-devel
    }
}

# System Python installation
export def system-python-install []: nothing -> nothing {
    si python3 python3-virtualenv pipx python3-pip python3-setuptools python3-wheel
    pipx install uv
    pipx ensurepath
}

# Locale setup
export def locale-setup []: nothing -> nothing {
    let locale = "en_US.UTF-8"
    let keymap = "us"

    sudo localectl set-locale LANG=$locale
    sudo localectl set-keymap $keymap
    sudo localectl set-x11-keymap $keymap
}

# Core installation
export def core-install []: nothing -> nothing {
    slog "Installing core packages"

    si 'dnf-command(copr)'
    si 'dnf-command(config-manager)'
    if not (is-fedora) {
        enable-epel
    }
    if (is-fedora) {
        si dnf5-plugins
    }

    update-packages

    si curl wget git-core trash-cli tree tar unzip util-linux-user which file

    if (is-fedora) {
        si stow
    }

    slog "Core packages installation done!"
}

# UI installation
export def ui-install []: nothing -> nothing {
    if not (is-desktop) {
        return
    }

    slog "Installing ui"

    si flatpak gnome-keyring wl-clipboard
    flathub-install

    slog "ui installation done!"
}

# Essential installation
export def essential-install []: nothing -> nothing {
    slog "Installing essential packages"

    pkgx-install

    base-dev-install

    si zip p7zip unar gawk readline-devel sqlite-devel libffi-devel \
        bzip2-devel xz-devel micro libsecret fuse fuse-libs zstd newt

    slog "Essential packages installation done!"
}

# CLI slim installation
export def cli-slim-install []: nothing -> nothing {
    slog "Installing cli tools using dnf"

    let base_pkgs = [zsh git ripgrep gh bat jq jc fzf]

    let fedora_pkgs = if (is-fedora) {
        [zoxide]
    } else {
        []
    }

    si ...$base_pkgs ...$fedora_pkgs

    slog "cli tools installation done!"
}

# CLI installation
export def cli-install []: nothing -> nothing {
    slog "Installing cli tools using dnf"

    cli-slim-install

    let base_pkgs = [neovim ShellCheck shfmt tmux htop pkg-config urlview
        plocate luarocks tealdeer lsd fd-find git-delta procs just dialog gum]

    let fedora_pkgs = if (is-fedora) {
        [python3-neovim hyperfine cheat navi ugrep direnv yq fastfetch]
    } else {
        []
    }

    si ...$base_pkgs ...$fedora_pkgs

    if (has-cmd tldr) {
        tldr --update
    }

    system-python-install

    slog "cli tools installation done!"
}

# Snap installation
export def snap-install []: nothing -> nothing {
    if (has-cmd snap) {
        return
    }

    slog "Installing snapd"
    si snapd
    sudo systemctl enable --now snapd.socket
    sudo systemctl enable --now snapd
    if not ("/snap" | path exists) {
        sudo ln -s /var/lib/snapd/snap /snap
    }

    slog "snapd setup done!"
}

# C++ installation
export def cpp-install []: nothing -> nothing {
    slog "Installing C++"

    si gcc gcc-c++ gdb valgrind systemtap ltrace strace clang clang-devel \
        clang-tools-extra clang-libs clang-analyzer lldb lld llvm llvm-devel \
        graphviz ccache cppcheck pre-commit cmake

    conan-install

    if (is-rocky) {
        si boost1.78 boost1.78-devel boost1.78-static catch-devel
    } else if (is-fedora) {
        si boost boost-devel boost-static catch-devel
    }

    slog "C++ installation done!"
}

# VSCode binary installation
export def vscode-binstall []: nothing -> nothing {
    if (has-cmd code) {
        return
    }

    slog "Installing vscode"

    vscode-fedora-repo

    dnf check-update
    si code

    slog "vscode installation done!"

    cmd-check code
}

# Terminal binary installation
export def terminal-binstall []: nothing -> nothing {
    if (has-cmd ghostty) {
        return
    }

    if (is-fedora) {
        slog "Installing ghostty"
        sudo dnf copr -y enable pgdev/ghostty
        si ghostty

        cmd-check ghostty
        slog "ghostty installation done!"
    } else {
        slog "Installing kitty"
        si kitty
        slog "kitty installation done!"

        if not (has-cmd kitty) {
            slog "Installing alacritty"
            si alacritty
            cmd-check alacritty
            slog "alacritty installation done!"
        }
    }
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
    si cockpit cockpit-machines cockpit-podman \
        cockpit-storaged cockpit-bridge cockpit-networkmanager cockpit-selinux \
        cockpit-system firewalld cockpit-packagekit

    sudo systemctl enable --now cockpit.socket
    sudo systemctl enable --now firewalld
    sudo firewall-cmd --add-service=cockpit
    sudo firewall-cmd --add-service=cockpit --permanent

    slog "cockpit installation done!"
}

# Docker installation
export def docker-install []: nothing -> nothing {
    if (has-cmd docker) {
        return
    }

    slog "Installing docker"

    docker-fedora-repo

    si docker-ce docker-ce-cli containerd.io docker-buildx-plugin \
        docker-compose-plugin dive slim

    slog "docker installation done!"
}

# Incus installation
export def incus-install []: nothing -> nothing {
    if (is-centos) {
        warn "incus not available for CentOS, skipping"
        return
    }

    if (has-cmd incus) {
        return
    }

    slog "Installing incus"

    if not (is-fedora) {
        sudo dnf -y copr enable neil/incus
    }

    si incus qemu-kvm qemu-img bridge-utils incus-agent openssl
    incus-confstall

    slog "incus installation done!"
}

# PM installation
export def pm-install []: nothing -> nothing {
    si net-tools iproute nmap lm_sensors stress-ng taliscale wireguard-tools smartmontools memtest86+ \
        glmark2
}

# VM installation
export def vm-install []: nothing -> nothing {
    slog "Installing libvirt"

    si libvirt virt-install bridge-utils virglrenderer cloud-utils bsdtar butane \
        qemu qemu-kvm qemu-img qemu-ui-spice-core qemu-ui-spice-app osinfo-db jc \
        qemu-char-spice qemu-audio-spice qemu-device-usb-redirect xmlstarlet lorax \
        qemu-device-display-virtio-vga qemu-device-display-virtio-gpu openssl jq \
        qemu-user-binfmt qemu-user-static qemu-system-x86_64 libosinfo dmidecode \
        coreos-installer pykickstart xorriso squashfs-tools osinfo-db-tools bootc \
        snapper btrfs-progs edk2-ovmf grub2-tools libguestfs-tools guestfs-tools

    slog "libvirt installation done!"
}

# Distrobox installation
export def distrobox-install []: nothing -> nothing {
    slog "Installing distrobox"
    si podman podman-compose podman-tui toolbox buildah distrobox
    slog "distrobox installation done!"
}

# More virt installation
export def more-virt-install []: nothing -> nothing {
    si samba-dcerpc samba-ldb-ldap-modules samba-winbind-clients
    si samba-winbind-modules samba
    si cockpit-bridge cockpit-selinux cockpit-storaged cockpit-system
    si cockpit-machines cockpit-networkmanager cockpit-system cockpit-storaged
    si cockpit-ostree cockpit-podman podman-tui podmansh powertop udica
    si libvirt-nss podman-bootc containerd.io
    si docker-ce docker-ce-cli docker-buildx-plugin docker-compose-plugin
}

# More UI installation
export def more-ui-install []: nothing -> nothing {
    si wireguard-tools xprop solaar stress-ng usbmuxd
    si mesa-libGLU playerctl pulseaudio-utils

    if (is-kde) {
        si libadwaita-qt5 libadwaita-qt6 kde-runtime-docs kdeplasma-addons
        si plasma-wallpapers-dynamic
    } else if (is-gnome) {
        si gnome-shell-extension-appindicator
        si gnome-shell-extension-caffeine gnome-shell-extension-dash-to-dock
        si gnome-shell-extension-gsconnect gnome-shell-extension-blur-my-shell
        si libgda libgda-sqlite
        si libratbag-ratbagd nautilus-gsconnect openssh-askpass yaru-theme
    }
}

# More fonts installation
export def more-fonts-install []: nothing -> nothing {
    si cascadia-code-fonts adobe-source-code-pro-fonts mozilla-fira-mono-fonts
    si jetbrains-mono-fonts-all google-go-mono-fonts ibm-plex-mono-fonts
    si google-droid-sans-mono-fonts powerline-fonts fira-code-fonts
}

# More essential installation
export def more-essential-install []: nothing -> nothing {
    bi glow gum lm_sensors stress-ng setools-console sysprof
    si rclone restic wl-clipboard samba tailscale wireguard-tools
    si git-credential-libsecret jetbrains-mono-fonts-all
    si edk2-ovmf genisoimage iotop p7zip-plugins p7zip
    si bash-color-prompt bcache-tools evtest fastfetch firewall-config
    si hplip ifuse input-remapper libimobiledevice libxcrypt-compat
}

# sin helper
export def sin [...packages: string]: nothing -> nothing {
    sudo dnf install -y --setopt=install_weak_deps=False ...$packages
}

# Desktop core installation
export def desktop-core-install []: nothing -> nothing {
    sin kitty wl-clipboard thunar thunar-archive-plugin gnome-keyring-pam \
        gnome-keyring libsecret udisks2 gvfs udiskie flatpak imagemagick

    flathub-install
    fpi app.zen_browser.zen

    jetbrains-mono-install
    font-awesome-install
    wallpapers-install
}

# WM tools installation
export def wm-tools-install []: nothing -> nothing {
    si waybar rofi rofi-wayland rofi-themes wlogout mako gnome-themes-extra \
        greetd network-manager-applet pavucontrol playerctl wlsunset
}

# WM installation
export def wm-install []: nothing -> nothing {
    slog "Installing tiling common packages"

    desktop-core-install
    wm-tools-install

    sin xdg-desktop-portal-gtk lxqt-policykit imv mpv grim slurp thunar \
        thunar-archive-plugin nwg-launchers qt6-qtsvg qt6-qtquickcontrols2 \
        google-noto-fonts-all google-noto-emoji-fonts \
        google-noto-color-emoji-fonts blueman bluez

    slog "Tiling common packages installation done!"
}

# Hyprland binary installation
export def hyprland-binstall []: nothing -> nothing {
    wm-install

    slog "Installing hyprland"

    sin hyprland hyprland-devel hyprutils hyprutils-devel hyprcursor

    slog "hyprland installation done!"
}

# Sway binary installation
export def sway-binstall []: nothing -> nothing {
    wm-install

    slog "Installing sway"

    si sway swaybg swayidle sway-systemd swaylock sddm-wayland-sway \
        sway-config-fedora

    terminal-binstall

    slog "sway installation done!"
}

# System docker installation
export def system-docker-install []: nothing -> nothing {
    if (has-cmd docker) {
        return
    }

    slog "Installing docker using os packages..."

    si docker docker-cli docker-compose

    slog "docker installation done!"
}

# Windsurf installation
export def windsurf-install []: nothing -> nothing {
    if (has-cmd windsurf) {
        return
    }

    slog "Installing windsurf"
    sudo rpm --import https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/yum/RPM-GPG-KEY-windsurf

    let repo_content = "[windsurf]
name=Windsurf Repository
baseurl=https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/yum/repo/
enabled=1
autorefresh=1
gpgcheck=1
gpgkey=https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/yum/RPM-GPG-KEY-windsurf"

    $repo_content | sudo tee /etc/yum.repos.d/windsurf.repo | ignore

    sudo dnf check-update
    si windsurf
    slog "windsurf installation done!"
}

# KDE slim binary installation
export def kde-slim-binstall []: nothing -> nothing {
    if not (is-fedora) {
        warn "KDE slim install only tested on fedora"
    }

    desktop-core-install

    slog "Installing kde plasma..."
    sin plasma-desktop plasma-discover systemsettings kscreen kio-extras \
        powerdevil power-profiles-daemon mesa-libGLES
    slog "kde plasma installation done!"
}

# KDE binary installation
export def kde-binstall []: nothing -> nothing {
    kde-slim-binstall

    sin plasma-discover-flatpak plasma-discover-packagekit
}

# Mango installation
export def mango-binstall []: nothing -> nothing {
    slog "Installing mango packages"
    desktop-core-install
    wm-install
    sudo dnf install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
    si mangowc
    slog "mango installation done!"
}

# Niri installation
export def niri-install []: nothing -> nothing {
    sudo dnf copr enable avengemedia/dms
    sudo dnf install -y niri dms sddm sddm-themes qt5ct qt6ct kitty sddm sddm-breeze
    systemctl --user add-wants niri.service dms
}
