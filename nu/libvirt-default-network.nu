#! /usr/bin/env nu

# Restore default libvirt network from existing XML files

use ./share/utils.nu *

# Main command
export def main [] {
    # Check if default network already exists
    let net_exists = try {
        sudo virsh net-info default | complete | get exit_code | $in == 0
    } catch { false }

    if $net_exists {
        info "Default network is already defined"
        let answer = yes-or-no "Do you want to delete it and recreate it?"

        if $answer {
            try {
                sudo virsh net-destroy default
            } catch {
                info "default network not active"
            }
            sudo virsh net-undefine default
        } else {
            info "Default network not touched"
            exit 0
        }
    }

    # Try to define from existing XML files
    let net_xml_paths = [
        "/etc/libvirt/qemu/networks/default.xml"
        "/usr/share/libvirt/networks/default.xml"
    ]

    mut defined = false
    for xml_path in $net_xml_paths {
        if ($xml_path | path exists) {
            sudo virsh net-define $xml_path
            $defined = true
            break
        }
    }

    if not $defined {
        die "Can't find default.xml in standard locations"
        exit 1
    }

    sudo virsh net-start default
    sudo virsh net-autostart default

    success "Default network is now defined and started"
}

