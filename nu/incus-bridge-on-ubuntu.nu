#! /usr/bin/env nu

# Create br0 bridge for Incus VMs/containers on Ubuntu (netplan + networkd)

use ./share/utils.nu *

const NETPLAN_FILE = "/etc/netplan/01-incus-br0.yaml"

# Detect primary NIC
export def detect-primary-nic []: nothing -> string {
    # Get first non-loopback, non-virtual ethernet device
    let links = try {
        ip -o link show | complete | get stdout | lines
    } catch { [] }

    for line in $links {
        let parts = $line | split row ": "
        if ($parts | length) < 2 {
            continue
        }
        let ifname = $parts | get 1 | str trim

        # Skip loopback and virtual interfaces
        if ($ifname != "lo") and ($ifname =~ "^e") {
            return $ifname
        }
    }

    ""
}

export def main [] {
    if not (is-root-user) {
        die "This script must be run as root"
    }

    let primary_nic = detect-primary-nic

    if ($primary_nic | is-empty) {
        die "Could not detect a primary NIC"
    }

    info $"Detected primary NIC: ($primary_nic)"
    info $"Writing netplan file: ($NETPLAN_FILE)"

    let netplan_content = $"network:
  version: 2
  renderer: networkd

  ethernets:
    ($primary_nic):
      dhcp4: false
      dhcp6: false

  bridges:
    br0:
      interfaces: [($primary_nic)]
      dhcp4: true
      dhcp6: true
"

    $netplan_content | sudo tee $NETPLAN_FILE | ignore

    info "Applying netplan..."
    sudo netplan apply

    # Configure Incus default profile
    info "Checking Incus default profile..."

    let profile_check = try {
        incus profile show default | complete | get stdout
    } catch { "" }

    let has_br0 = $profile_check | str contains "parent: br0"

    if not $has_br0 {
        info "Setting br0 as default Incus network..."
        incus profile device set default eth0 parent br0
    } else {
        info "Incus default profile already uses br0."
    }

    success "Done. Your host now uses br0 bridge, and Incus instances will obtain IP from router DHCP."
}

