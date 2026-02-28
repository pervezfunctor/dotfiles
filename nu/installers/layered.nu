#! /usr/bin/env nu

# Atomic/rpm-ostree installer functions

use ../share/utils.nu *
use common.nu *

# rpm-ostree groups setup
export def rpm-ostree-groups-setup [...groups: string]: nothing -> nothing {
    for grp in $groups {
        # fix_group_for_atomic equivalent would go here
        add-user-to-group $env.USER $grp
    }
}

# rpm-ostree incus groups setup
export def rpm-ostree-incus-groups-setup []: nothing -> nothing {
    rpm-ostree-groups-setup incus incus-admin kvm qemu
}

# rpm-ostree libvirt groups setup
export def rpm-ostree-libvirt-groups-setup []: nothing -> nothing {
    rpm-ostree-groups-setup libvirt kvm qemu
}

# Check if rpm package is installed
export def rpm-installed [pkg: string]: nothing -> bool {
    try { rpm -q $pkg | complete | get exit_code | $in == 0 } catch { false }
}

# Filter packages that aren't installed
export def filter-packages [...packages: string]: nothing -> list<string> {
    $packages | where { |pkg| not (rpm-installed $pkg) }
}

# Core layered packages
export def core-layered []: nothing -> list<string> {
    filter-packages stow zsh git tmux gcc make bootc coreos-installer openssl \
        gnome-keyring wl-clipboard
}

# VSCode layered packages
export def vscode-layered []: nothing -> list<string> {
    let vscode_repo = "/etc/yum.repos.d/vscode.repo"
    if not (has-cmd code) and not ($vscode_repo | path exists) {
        let repo_content = "[code]
name=Visual Studio Code:
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc"
        $repo_content | sudo tee $vscode_repo | ignore
    }

    filter-packages code
}

# Libvirt layered packages
export def libvirt-layered []: nothing -> list<string> {
    filter-packages libvirt libvirt-nss virt-manager virt-install libguestfs-tools \
        guestfs-tools
}

# Incus layered packages
export def incus-layered []: nothing -> list<string> {
    filter-packages qemu-kvm incus incus-agent incus-selinux incus-tools
}

# Layered install function
export def layered-install [...layers: string]: nothing -> nothing {
    let fns = []
    let pkgs = []

    for layer in $layers {
        let fn = $"($layer)-layered"
        let fn_exists = (scope commands | where name == $fn | is-not-empty)
        if $fn_exists {
            $fns | append $fn
        } else {
            warn $"Layer function ($fn) does not exist, skipping"
        }
    }

    # Collect packages from layer functions
    for f in $fns {
        let layer_pkgs = (run-external $f)
        $pkgs | append $layer_pkgs
    }

    let unique_pkgs = ($pkgs | uniq)

    if ($unique_pkgs | length) == 0 {
        slog "No packages to install"
        sleep 3sec
        return
    }

    slog $"Installing packages: ($unique_pkgs | str join ' ')"

    if not (sudo rpm-ostree install -y ...$unique_pkgs | complete | get exit_code | $in == 0) {
        fail "rpm-ostree install failed"
        return
    }

    warn "Installing packages done! Note that you need to reboot for the changes to take effect."
}

# rpm-ostree install
export def rpm-ostree-install []: nothing -> nothing {
    if not (has-cmd rpm-ostree) {
        die "This script is only for rpm-ostree based systems"
    }

    slog "Installing packages"

    let pkgs = []
    let pkgs = $pkgs | append (core-layered)
    let pkgs = $pkgs | append (vscode-layered)
    let pkgs = $pkgs | append (libvirt-layered)

    if ($pkgs | length) == 0 {
        slog "No packages to install"
        sleep 3sec
        return
    }

    if (has-cmd stow) or (has-cmd zsh) or (has-cmd gcc) or (has-cmd make) or
       (has-cmd tmux) or (has-cmd virsh) or
       (has-cmd virt-install) or (has-cmd code) {
        warn "This script is supposed to be run only once"
    }

    slog $"Installing packages ($pkgs | str join ' ')"
    sudo rpm-ostree install -y ...$pkgs

    warn "Installing packages done! Note that you need to reboot for the changes to take effect."
}

# rpm-ostree post-install
export def rpm-ostree-post-install []: nothing -> nothing {
    vscode-confstall
    python-install

    if (has-cmd virt-install) {
        rpm-ostree-libvirt-groups-setup
        sudo systemctl enable --now libvirtd
    }
}

# rpm-ostree mainstall
export def rpm-ostree-mainstall []: nothing -> nothing {
    rpm-ostree-install
    generic-mainstall
    # homebrew-atomic check would go here
}
