#! /usr/bin/env nu

# Restore the default libvirt network (virbr0) if it's missing or not working

use ./share/utils.nu *

# Check network status
export def check-network-status []: nothing -> bool {
    info "Checking libvirt default network status..."

    # Check if default network exists
    let net_info = try {
        sudo virsh net-info default | complete
    } catch {
        return false
    }

    if $net_info.exit_code != 0 {
        die "Default network does not exist!"
        return false
    }

    # Parse network info
    let info_lines = $net_info.stdout | lines
    let active = $info_lines | parse "Active:{value}" | get 0?.value? | default "" | str trim
    let autostart = $info_lines | parse "Autostart:{value}" | get 0?.value? | default "" | str trim

    info $"Network status: Active=($active), Autostart=($autostart)"

    # Check virbr0 interface
    let virbr0_check = try {
        ip addr show virbr0 | complete
    } catch {
        { exit_code: 1 }
    }

    if $virbr0_check.exit_code == 0 {
        let virbr0_ip = $virbr0_check.stdout | lines | find "inet " | first? | default "" | parse "inet {ip} " | get 0?.ip? | default ""
        info $"virbr0 interface: ($virbr0_ip)"

        if ($virbr0_ip | str contains "192.168.122.1/24") {
            success "virbr0 interface has correct IP address"
        } else {
            warn $"virbr0 interface has unexpected IP: ($virbr0_ip)"
        }
    } else {
        warn "virbr0 interface not found"
    }

    # Return status
    ($active == "yes") and ($autostart == "yes")
}

# Clean up conflicting interfaces
export def clean-conflicting-interfaces []: nothing -> nothing {
    info "Cleaning up conflicting interfaces..."

    # Kill any dnsmasq processes for virbr0
    let dnsmasq_pids = try {
        pgrep -f "dnsmasq.*virbr0" | complete | get stdout | lines
    } catch {
        []
    }

    if ($dnsmasq_pids | length) > 0 {
        info "Stopping dnsmasq processes for virbr0..."
        for pid in $dnsmasq_pids {
            try { sudo kill $pid } catch {}
        }
    }

    # Remove virbr0 interface if it exists
    let virbr0_exists = try {
        ip link show virbr0 | complete | get exit_code | $in == 0
    } catch { false }

    if $virbr0_exists {
        info "Removing existing virbr0 interface..."
        try { sudo ip link set virbr0 down } catch {}
        try { sudo ip link delete virbr0 } catch {}
    }

    success "Cleanup completed"
}

# Restore the network
export def restore-network []: nothing -> nothing {
    info "Restoring default libvirt network..."

    # Ensure libvirtd is enabled and running
    info "Ensuring libvirtd service is enabled and running..."
    sudo systemctl enable --now libvirtd
    sleep 2sec

    # Start the default network
    info "Starting default network..."
    let start_result = try {
        sudo virsh net-start default | complete
    } catch { { exit_code: 1 } }

    if $start_result.exit_code == 0 {
        success "Default network started"
    } else {
        warn "Failed to start default network, trying with libvirtd restart..."
        info "Restarting libvirtd to clear any conflicts..."
        sudo systemctl restart libvirtd
        sleep 3sec

        let retry_result = try {
            sudo virsh net-start default | complete
        } catch { { exit_code: 1 } }

        if $retry_result.exit_code == 0 {
            success "Default network started after restart"
        } else {
            die "Failed to start default network even after restart"
            exit 1
        }
    }

    # Enable autostart
    info "Enabling autostart for default network..."
    let autostart_result = try {
        sudo virsh net-autostart default | complete
    } catch { { exit_code: 1 } }

    if $autostart_result.exit_code == 0 {
        success "Autostart enabled for default network"
    } else {
        die "Failed to enable autostart"
        exit 1
    }

    sleep 3sec
    success "Network restoration completed"
}

# Verify network
export def verify-network []: nothing -> bool {
    info "Verifying network configuration..."

    # Check network status
    if not (check-network-status) {
        die "Network verification failed"
        return false
    }

    # Check virbr0 IP
    let virbr0_ip_check = try {
        ip addr show virbr0 | complete | get stdout | str contains "192.168.122.1/24"
    } catch { false }

    if not $virbr0_ip_check {
        die "virbr0 interface does not have the expected IP address"
        return false
    }

    # Check dnsmasq
    let dnsmasq_running = try {
        pgrep -f "dnsmasq.*virbr0" | complete | get exit_code | $in == 0
    } catch { false }

    if not $dnsmasq_running {
        warn "dnsmasq is not running for virbr0 (this might be normal)"
    } else {
        success "dnsmasq is running for virbr0"
    }

    success "Network verification passed"
    true
}

# Main command
export def main [
    --force          # Force recreation of the network even if it appears to be working
    --help (-h)      # Show help message
] {
    # Check if running as root (should NOT be root)
    if (is-root-user) {
        die "This script should not be run as root"
        die "It will use sudo when needed"
        exit 1
    }

    # Check if libvirtd is installed
    if not (has-cmd virsh) {
        die "libvirt is not installed"
        exit 1
    }

    # Check if libvirtd is running
    let libvirtd_active = try {
        systemctl is-active libvirtd | complete | get stdout | str trim | $in == "active"
    } catch { false }

    if not $libvirtd_active {
        warn "libvirtd service is not running, attempting to start it..."
        let start_result = try {
            sudo systemctl enable --now libvirtd | complete
        } catch { { exit_code: 1 } }

        if $start_result.exit_code == 0 {
            success "libvirtd service started"
            sleep 2sec
        } else {
            die "Failed to start libvirtd service"
            exit 1
        }
    }

    info "Starting libvirt network restoration..."

    # Check if we need to restore
    if (not $force) and (check-network-status) {
        success "Default network is already working correctly"
        info "Use --force to recreate the network anyway"
        exit 0
    }

    clean-conflicting-interfaces
    restore-network

    if (verify-network) {
        success "Libvirt default network has been successfully restored!"
        info "Your VM automation scripts should now work correctly"
    } else {
        die "Network restoration completed but verification failed"
        exit 1
    }
}

