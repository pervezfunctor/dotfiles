#! /usr/bin/env nu

# Debian/Ubuntu (APT) installer functions

use ../share/utils.nu *
use common.nu *

# Main package install function with availability check
export def si [...packages: string]: nothing -> nothing {
    let found = []
    let not_found = []

    for pkg in $packages {
        let available = (apt-cache show $pkg | complete | get exit_code | $in == 0)
        if $available {
            $found | append $pkg
        } else {
            $not_found | append $pkg
        }
    }

    if ($found | length) > 0 {
        sudo apt-get -qq -y install ...$found
    }

    for pkg in $not_found {
        warn $"Package ($pkg) not found in apt repository"
    }
}

# Check if running on legacy APT (Ubuntu < 25.04 or Debian < 13)
export def is-legacy-apt []: nothing -> bool {
    if (is-zorin) { return true }

    let uver = (try { ubuntu-major-version } catch { 0 })
    let dver = (try { debian-version | into int } catch { 0 })

    if ($uver > 0) and ($uver < 25) { return true }
    if ($dver > 0) and ($dver < 13) { return true }

    false
}

# FZF installation (with legacy check)
export def fzf-install []: nothing -> nothing {
    if (is-legacy-apt) {
        sudo apt purge -y fzf
        warn "not installing fzf: too old version"
    } else {
        si fzf
    }
}

# Pacstall installation
export def pacstall-install []: nothing -> nothing {
    if (has-cmd pacstall) {
        return
    }

    sudo bash -c "$(curl -fsSL https://pacstall.dev/q/install)"
}

# Update packages
export def update-packages []: nothing -> nothing {
    slog "Updating packages..."

    let update_result = try { sudo apt-get -qq update | complete } catch { { exit_code: 1 } }
    if $update_result.exit_code != 0 {
        die "apt-get update failed, quitting"
    }
    let upgrade_result = try { sudo apt-get -qq upgrade -y | complete } catch { { exit_code: 1 } }
    if $upgrade_result.exit_code != 0 {
        die "apt-get upgrade failed, quitting"
    }

    slog "Updating packages done!"
}

# Ubuntu packages installation
export def ubuntu-packages []: nothing -> nothing {
    update-packages

    slog "Installing ubuntu packages..."

    si git-core gh git-delta unzip wget curl net-tools iproute2 nmap gum eza \
        trash-cli tar stow gcc make file tree bat ripgrep gawk starship pipx \
        zoxide fd-find htop sd bat dialog whiptail tealdeer yq python3 python3-pip

    fzf-install

    if (has-cmd tldr) {
        tldr --update
    }

    slog "Installing ubuntu packages done!"
}

# Proxmox packages
export def proxmox-packages []: nothing -> nothing {
    slog "Installing packages..."

    apt-get -qq -y --no-install-recommends install git-core micro zsh curl wget \
        zsh-theme-powerlevel9k htop pciutils ripgrep rclone stow stress jq yq sudo \
        smartmontools zfsutils-linux rsync whiptail dialog numactl fio dysk duf jc \
        usbutils restic ethtool nvme-cli lsof lm-sensors udisks2 guestfs-tools \
        proxmox-backup-client libguestfs-tools
}

# Proxmox mainstall
export def proxmox-mainstall []: nothing -> nothing {
    if not (is-proxmox) {
        die "System not proxmox. Quitting."
    }
    if not (is-root-user) {
        die "This should be run as root. sudo not allowed"
    }

    slog "Starting proxmox installation..."

    let community_scripts_base = "https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main"

    slog "Running post PVE installation script..."
    bash -c $"(curl -fsSL ($community_scripts_base)/tools/pve/post-pve-install.sh)"

    proxmox-packages

    if not (dir-exists $env.DOT_DIR) {
        slog "Cloning dotfiles..."
        git clone https://github.com/pervezfunctor/dotfiles.git $env.DOT_DIR
        slog "Dotfiles cloned successfully!"
    }

    let bashrc = ~/.bashrc | path expand
    let has_source = if ($bashrc | path exists) {
        let content = open $bashrc
        $content | str contains "source ~/.ilm/share/bashrc"
    } else {
        false
    }

    if not $has_source {
        echo "source ~/.ilm/share/bashrc" >> ~/.bashrc
    }

    backup-file ~/.zshrc
    ln -sf ($env.DOT_DIR | path join "share" "dot-zshrc") ~/.zshrc

    slog "Installing CPU governor scaling..."
    bash -c $"(curl -fsSL ($community_scripts_base)/tools/pve/scaling-governor.sh)"

    slog "proxmox installation completed!"
}

# Debian locale installation
export def debian-locale-install [locale_to_use: string = "en_US.UTF-8"]: nothing -> nothing {
    si locales

    let locale_gen = "/etc/locale.gen"
    let has_locale = if ($locale_gen | path exists) {
        let content = open $locale_gen
        $content | str contains $"^($locale_to_use) UTF-8"
    } else {
        false
    }

    if not $has_locale {
        echo $"($locale_to_use) UTF-8" | sudo tee -a $locale_gen | ignore
    }

    sudo sed -i $"s/^# *($locale_to_use) UTF-8/($locale_to_use) UTF-8/" $locale_gen

    sudo locale-gen
    sudo update-locale LANG=$locale_to_use

    locale
}

# Locale setup
export def locale-setup []: nothing -> nothing {
    slog "Setting locale to en_US.UTF-8..."
    si locales
    sudo locale-gen en_US.UTF-8
    sudo update-locale LANG=en_US.UTF-8

    slog "Setting keyboard layout to US..."
    sudo localectl set-keymap us
    sudo localectl set-x11-keymap us

    echo "export LANGUAGE=en" | sudo tee -a /etc/default/locale | ignore
    echo "export COUNTRY=US" | sudo tee -a /etc/default/locale | ignore

    # Force console keymap now
    sudo loadkeys us

    slog "Configuration complete. You may need to reboot for all changes to take effect."
}

# Debian packages installation
export def debian-packages []: nothing -> nothing {
    update-packages
    debian-locale-install
    slog "Installing debian packages..."

    si stow git-core gh git-delta lazygit unzip wget curl trash-cli python3-pip \
        net-tools iproute2 nmap gcc make file tree ripgrep zoxide fd-find htop tar \
        gawk tealdeer dialog whiptail starship hyperfine jq jc direnv yq dysk bat \
        just gum eza shellcheck shfmt broot duf sd xh atuin procs sd python3 pipx

    fzf-install

    if (is-desktop) {
        si wl-clipboard libsecret-tools
    }

    if (has-cmd tldr) {
        tldr --update
    }

    slog "Installing debian packages done!"
}

# Core installation
export def core-install []: nothing -> nothing {
    update-packages
    if (is-debian) {
        debian-locale-install
    }

    slog "Installing core packages..."

    if (is-ubuntu) {
        si software-properties-common
    }
    si apt-transport-https ca-certificates gpg curl wget git-core trash-cli \
        tar unzip tree file stow

    slog "Core packages installation done!"
}

# Snap installation
export def snap-install []: nothing -> nothing {
    if (has-cmd snap) {
        return
    }

    slog "Installing snap..."
    si snapd
    sudo systemctl enable --now snapd.socket
    sudo systemctl enable --now snapd

    sudo snap install core
    slog "snap installation done!"
}

# UI installation
export def ui-install []: nothing -> nothing {
    if not (is-desktop) {
        return
    }

    slog "Installing ui..."

    si libsecret-tools gnome-keyring wl-clipboard flatpak
    flathub-install

    slog "ui installation done!"
}

# Essential installation
export def essential-install []: nothing -> nothing {
    slog "Installing essential packages..."

    pkgx-install

    if (is-legacy-apt) {
        si perl
        pkgx pkgm install stow
    }

    if ("/run/systemd/system" | path exists) and not (is-debian) {
        snap-install
    }

    si zip unar micro p7zip libreadline-dev libsqlite3-dev libffi-dev libfuse2 \
        libbz2-dev liblzma-dev libsecret-tools build-essential whiptail zstd gawk \
        command-not-found firmware-linux linux-headers-(^uname -r | str trim)

    slog "Essential packages installation done!"
}

# CLI slim installation
export def cli-slim-install []: nothing -> nothing {
    si zsh git starship ripgrep gh zoxide eza
    fzf-install
}

# System Python installation
export def system-python-install []: nothing -> nothing {
    slog "Installing python..."

    si python3 python3-venv python3-virtualenv python3-pip python3-setuptools \
        python3-wheel python-is-python3 pipx

    pipx install uv

    slog "Python installation done!"

    cmd-check uv
}

# CLI installation
export def cli-install []: nothing -> nothing {
    slog "Installing cli tools using apt..."

    cli-slim-install

    si tmux pkg-config urlview plocate htop gdu hyperfine fd-find ugrep tealdeer \
        direnv yq shellcheck shfmt sd bat jq jc git-delta dialog gum just fastfetch

    if (has-cmd tldr) {
        tldr --update
    }

    system-python-install

    slog "cli tools installation done!"
}

# C++ installation
export def cpp-install []: nothing -> nothing {
    slog "Installing C++..."

    si gcc gdb g++ libboost-all-dev catch2 clang llvm clang-tidy clang-format \
        clang-tools libclang-dev clangd doxygen graphviz ccache cppcheck \
        pre-commit valgrind systemtap ltrace strace lldb lld cmake

    conan-install

    cmd-check gcc g++ gdb clang clang-tidy clang-format
    cmd-check cmake conan

    slog "C++ installation done!"
}

# VSCode binary installation
export def vscode-binstall []: nothing -> nothing {
    if (has-cmd code) {
        return
    }

    slog "Installing vscode..."

    let vscode_list = "/etc/apt/sources.list.d/vscode.list"
    let has_repo = if ($vscode_list | path exists) {
        let content = open $vscode_list
        $content | str contains "https://packages.microsoft.com/repos/code"
    } else {
        false
    }

    if not $has_repo {
        echo "code code/add-microsoft-repo boolean true" | sudo debconf-set-selections

        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg

        echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee $vscode_list | ignore

        rm -f packages.microsoft.gpg
    }

    sudo apt-get -qq update
    si code

    slog "vscode installation done!"

    cmd-check code
}

# Windsurf installation
export def windsurf-install []: nothing -> nothing {
    if (has-cmd windsurf) {
        return
    }

    slog "Installing windsurf..."

    let windsurf_list = "/etc/apt/sources.list.d/windsurf.list"
    if not ($windsurf_list | path exists) {
        curl -fsSL "https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/windsurf.gpg" | sudo gpg --dearmor -o /usr/share/keyrings/windsurf-stable-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/windsurf-stable-archive-keyring.gpg arch=amd64] https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/apt stable main" | sudo tee $windsurf_list | ignore
    }

    sudo apt-get -qq update
    si windsurf

    slog "windsurf installation done!"
}

# Terminal binary installation
export def terminal-binstall []: nothing -> nothing {
    if (has-cmd ghostty) {
        return
    }
    if (has-cmd kitty) {
        return
    }

    slog "Installing terminal..."
    if (has-cmd snap) {
        snap install ghostty --classic
    }

    if (has-cmd ghostty) {
        slog "ghostty installed"
    } else {
        si kitty
        if not (has-cmd kitty) {
            si alacritty
        }
    }

    if not ((has-cmd kitty) or (has-cmd alacritty)) {
        warn "No terminal installed"
    }

    slog "terminal installation done!"
}

# VM UI installation
export def vm-ui-install []: nothing -> nothing {
    if not (is-desktop) {
        return
    }

    slog "Installing virt ui packages..."

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

    slog "Installing cockpit..."

    si cockpit cockpit-machines cockpit-networkmanager cockpit-packagekit \
        cockpit-sosreport cockpit-pcp cockpit-podman cockpit-storaged \
        cockpit-system

    sudo systemctl enable --now cockpit.socket

    slog "cockpit installation done!"
}

# VM installation
export def vm-install []: nothing -> nothing {
    slog "Installing libvirt..."

    si libvirt-daemon-system qemu-system-x86 virtinst bridge-utils libosinfo-bin \
        virgl-server qemu-utils spice-client-gtk spice-vdagent jq jc xmlstarlet \
        cloud-image-utils libguestfs-tools osinfo-db edk2-ovmf edk2-ovmf dmidecode \
        osinfo-db-tools openssl

    slog "libvirt installation done!"
}

# Incus installation
export def incus-install []: nothing -> nothing {
    if (has-cmd incus) {
        return
    }

    slog "Installing incus..."

    si qemu-system-x86 qemu-utils incus bridge-utils openssl

    incus-confstall

    slog "incus-lts installation done!"
}

# Incus latest installation
export def incus-latest-install []: nothing -> nothing {
    if (has-cmd incus) {
        return
    }

    slog "Installing incus..."

    sudo mkdir -p /etc/apt/keyrings/
    sudo curl -fsSL https://pkgs.zabbly.com/key.asc -o /etc/apt/keyrings/zabbly.asc

    let suite = open /etc/os-release | lines | parse "{{key}}={{value}}" | where key == "VERSION_CODENAME" | get 0.value | str trim -c '"'
    let arch = dpkg --print-architecture
    let sources_content = $"Enabled: yes
Types: deb
URIs: https://pkgs.zabbly.com/incus/stable
Suites: ($suite)
Components: main
Architectures: ($arch)
Signed-By: /etc/apt/keyrings/zabbly.asc"

    $sources_content | sudo tee /etc/apt/sources.list.d/zabbly-incus-stable.sources | ignore

    update-packages

    si incus bridge-utils qemu-system-x86 qemu-utils

    incus-confstall

    slog "incus installation done!"
}

# Distrobox installation
export def distrobox-install []: nothing -> nothing {
    if (has-cmd distrobox) {
        return
    }

    slog "Installing distrobox..."

    si podman podman-toolbox podman-compose
    slog "podman installation done!"

    si buildah distrobox

    slog "distrobox installation done!"
}

# PM installation
export def pm-install []: nothing -> nothing {
    si net-tools iproute2 nmap lm_sensors stress-ng taliscale wireguard-tools \
        smartmontools memtest86+ glmark2
}

# sin helper (install if available)
export def sin [...packages: string]: nothing -> nothing {
    for pkg in $packages {
        let available = (apt-cache show $pkg | complete | get exit_code | $in == 0)
        if $available {
            sudo apt install --no-install-recommends -y -qq $pkg
        } else {
            warn $"Package ($pkg) not found in apt repository"
        }
    }
}

# Desktop core installation
export def desktop-core-install []: nothing -> nothing {
    sin kitty wl-clipboard gnome-keyring libsecret-tools imagemagick libgl1-mesa \
        papirus-icon-theme bibata-cursor-theme udisks2 udiskie gvfs flatpak \
        libgles2-mesa imagemagick

    flathub-install
    fpi app.zen_browser.zen

    jetbrains-mono-install
    font-awesome-install
    wallpapers-install
}

# WM tools installation
export def wm-tools-install []: nothing -> nothing {
    sin waybar rofi wofi mako dunst wlogout pavucontrol
}

# WM installation
export def wm-install []: nothing -> nothing {
    desktop-core-install
    wm-tools-install

    sin grim slurp cliphist mpv thunar thunar-archive-plugin xdg-desktop-portal \
        fonts-noto fonts-noto-mono fonts-noto-color-emoji nwg-look nwg-displays nvtop imv fonts-inter
}

# Sway binary installation
export def sway-binstall []: nothing -> nothing {
    slog "Installing sway..."

    wm-install

    sin sway swaylock swayidle swaybg xdg-desktop-portal-gtk \
        polkit-kde-agent-1 sway-notification-center swappy nm-connection-editor \
        network-manager-applet

    slog "sway installation done!"
}

# KDE slim binary installation
export def kde-slim-binstall []: nothing -> nothing {
    slog "Installing minimal kde plasma..."

    desktop-core-install
    sin kde-plasma-desktop kscreen systemsettings udisks2 powerdevil \
        power-profiles-daemon

    sin libgles2-mesa
    sin libgl1-mesa

    slog "kde plasma installation done!"
}

# KDE binary installation
export def kde-binstall []: nothing -> nothing {
    kde-slim-binstall
    sin plasma-discover plasma-discover-backend-flatpak
    sin plasma-discover-backend-fwupd
}

# System docker binary installation
export def system-docker-binstall []: nothing -> nothing {
    if (has-cmd docker) {
        return
    }

    slog "Installing docker using os packages..."

    si docker.io docker-compose-v2 slim
}

# Niri binary installation
export def niri-binstall []: nothing -> nothing {
    if (is-legacy-apt) or (is-debian) {
        warn "niri not supported on this distro"
        return
    }

    sudo add-apt-repository ppa:avengemedia/danklinux
    sudo add-apt-repository ppa:avengemedia/dms
    sudo apt install niri dms sddm sddm-themes
}

# Check if is zorin
export def is-zorin []: nothing -> bool {
    if not ("/etc/os-release" | path exists) {
        return false
    }
    let os = (open /etc/os-release | str downcase)
    $os | str contains "zorin"
}
