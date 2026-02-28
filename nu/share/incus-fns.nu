#! /usr/bin/env nu

use utils.nu

# ============================================
# Incus Container Functions
# ============================================

export def incus-ubuntu-lxc []: nothing -> nothing {
    incus launch images:ubuntu/25.10 ubuntu
}

export def incus-fedora-lxc []: nothing -> nothing {
    incus launch images:fedora/43 fedora
}

export def incus-tw-lxc []: nothing -> nothing {
    incus launch images:opensuse/tumbleweed tw
}

export def incus-arch-lxc []: nothing -> nothing {
    incus launch images:archlinux/current archlinux
}

export def incus-containers []: nothing -> nothing {
    slog "Creating incus containers"

    incus-ubuntu-lxc
    incus-fedora-lxc
    incus-tw-lxc
    incus-arch-lxc

    slog "Creating incus containers done!"
}

# ============================================
# Incus VM Functions
# ============================================

export def incus-ubuntu-vm []: nothing -> nothing {
    incus launch images:ubuntu/25.10 ubuntu-vm --vm
}

export def incus-fedora-vm []: nothing -> nothing {
    incus launch images:fedora/43 fedora-vm --vm
}

export def incus-tw-vm []: nothing -> nothing {
    incus launch images:opensuse/tumbleweed-vm tw --vm
}

export def incus-arch-vm []: nothing -> nothing {
    incus launch images:archlinux/current archlinux-vm --vm
}

export def incus-nixos []: nothing -> nothing {
    incus launch images:nixos/unstable --vm nixos-vm -c security.secureboot=false
}
