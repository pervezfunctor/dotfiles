#! /usr/bin/env nu

# Fix iptables/ufw rules for libvirt network to work alongside Docker

use ./share/utils.nu *

const LIBVIRT_NET = "virbr0"
const LIBVIRT_SUBNET = "192.168.122.0/24"

# Main command
export def main [
    out_if: string  # Outgoing interface (e.g., eth0)
] {
    if ($out_if | is-empty) {
        die "Please provide the outgoing interface (e.g., eth0) as an argument"
        info "Usage: libvirt-network-fix <OUT_IF> (e.g. eth0)"
        exit 1
    }

    if not (has-cmd iptables) {
        info "iptables is not available. You may not need this fix."
        exit 0
    }

    if (has-cmd iptables) {
        info "Flushing existing FORWARD rules for libvirt and docker chains..."

        # Remove old rules (ignore errors)
        try {
            sudo iptables -D FORWARD -i $LIBVIRT_NET -o $out_if -j ACCEPT
        } catch {}
        try {
            sudo iptables -D FORWARD -i $out_if -o $LIBVIRT_NET -m state --state RELATED,ESTABLISHED -j ACCEPT
        } catch {}

        # Add new rules
        sudo iptables -A FORWARD -i $LIBVIRT_NET -o $out_if -j ACCEPT
        sudo iptables -A FORWARD -i $out_if -o $LIBVIRT_NET -m state --state RELATED,ESTABLISHED -j ACCEPT

        info "Setting up NAT (MASQUERADE) for libvirt subnet..."
        try {
            sudo iptables -t nat -D POSTROUTING -s $LIBVIRT_SUBNET ! -o $LIBVIRT_NET -j MASQUERADE
        } catch {}
        sudo iptables -t nat -A POSTROUTING -s $LIBVIRT_SUBNET ! -o $LIBVIRT_NET -j MASQUERADE

        success "Done. You should now have internet access from libvirt guests alongside Docker."

        echo ""
        info "Current FORWARD chain rules (summary):"
        sudo iptables -L FORWARD -v -n | find $LIBVIRT_NET $out_if

        echo ""
        info "Current POSTROUTING nat rules (summary):"
        sudo iptables -t nat -L POSTROUTING -v -n | find MASQUERADE

    } else if (has-cmd ufw) {
        # Allow DNS for libvirt's dnsmasq
        sudo ufw allow in on virbr0 to any port 53 proto udp
        sudo ufw allow in on virbr0 to any port 53 proto tcp

        # Allow DHCP
        sudo ufw allow in on virbr0 to any port 67 proto udp
        sudo ufw allow in on virbr0 to any port 68 proto udp

        # Allow traffic from libvirt bridge to outside
        sudo ufw route allow in on virbr0 out on $out_if

        # Allow established/related traffic
        sudo ufw allow in on virbr0 from $LIBVIRT_SUBNET

        success "Done. You should now have internet access from libvirt guests alongside Docker."

        echo ""
        info "Current ufw status (summary):"
        sudo ufw status numbered
    }
}

