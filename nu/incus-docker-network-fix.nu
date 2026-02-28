#! /usr/bin/env nu

# Fix Incus networking for Docker containers

use ./share/utils.nu *

const DEFAULT_SUBNET = "10.105.245.0/24"

# Validate CIDR subnet format
export def validate-subnet [subnet: string]: nothing -> bool {
    # Basic CIDR validation using regex
    let cidr_regex = '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/\d{1,2}$'
    let is_valid = ($subnet | find -r $cidr_regex | is-not-empty)

    if not $is_valid {
        return false
    }

    # Additional check using ip route
    let ip_check = try {
        ip route get $subnet | complete | get exit_code | $in == 0
    } catch { false }

    $ip_check
}

# Check prerequisites
export def check-prerequisites []: nothing -> bool {
    mut missing = false

    # Check if running as root or with sudo
    if not (is-root-user) {
        info "This script requires root privileges. Checking sudo access..."
        let sudo_check = try {
            sudo -n true | complete | get exit_code | $in == 0
        } catch { false }

        if not $sudo_check {
            die "This script requires root privileges. Please run with sudo or as root."
            $missing = true
        }
    }

    # Check required commands
    let required_cmds = [ip sysctl]
    for cmd in $required_cmds {
        if not (has-cmd $cmd) {
            die $"Required command '($cmd)' is not available."
            $missing = true
        }
    }

    # Check for packet filtering tool
    if (not (has-cmd iptables)) and (not (has-cmd nft)) {
        die "Neither iptables nor nftables is available."
        $missing = true
    }

    # Check ip_forward exists
    if not ("/proc/sys/net/ipv4/ip_forward" | path exists) {
        die "IPv4 forwarding not supported on this system."
        $missing = true
    }

    # Check sysctl.d is writable
    if not ("/etc/sysctl.d" | path exists) {
        die "Cannot write to /etc/sysctl.d. Check permissions."
        $missing = true
    }

    if $missing {
        die "Prerequisites check failed. Please resolve the issues above and try again."
        return false
    }

    success "All prerequisites satisfied"
    true
}

# Configure firewalld
export def configure-firewalld [bridge_name: string]: nothing -> bool {
    if not (has-cmd firewall-cmd) {
        info "firewalld not available, skipping firewalld configuration"
        return true
    }

    let firewalld_active = try {
        systemctl is-active firewalld | complete | get stdout | str trim | $in == "active"
    } catch { false }

    if not $firewalld_active {
        info "firewalld not running, skipping firewalld configuration"
        return true
    }

    info $"Configuring firewalld for bridge: ($bridge_name)"

    let add_result = try {
        sudo firewall-cmd --zone=trusted --change-interface=$bridge_name --permanent | complete
    } catch { { exit_code: 1 } }

    if $add_result.exit_code != 0 {
        die $"Failed to add ($bridge_name) to trusted zone"
        return false
    }
    success $"Added ($bridge_name) to trusted zone permanently"

    let reload_result = try {
        sudo firewall-cmd --reload | complete
    } catch { { exit_code: 1 } }

    if $reload_result.exit_code != 0 {
        die "Failed to reload firewalld configuration"
        return false
    }
    success "Reloaded firewalld configuration"

    true
}

# Configure UFW
export def configure-ufw [bridge_name: string]: nothing -> bool {
    if not (has-cmd ufw) {
        info "UFW not available, skipping UFW configuration"
        return true
    }

    info $"Configuring UFW for bridge: ($bridge_name)"

    let in_result = try {
        sudo ufw allow in on $bridge_name | complete
    } catch { { exit_code: 1 } }

    if $in_result.exit_code != 0 {
        die $"Failed to allow incoming traffic on ($bridge_name)"
        return false
    }
    success $"Allowed incoming traffic on ($bridge_name)"

    let out_result = try {
        sudo ufw allow out on $bridge_name | complete
    } catch { { exit_code: 1 } }

    if $out_result.exit_code != 0 {
        die $"Failed to allow outgoing traffic on ($bridge_name)"
        return false
    }
    success $"Allowed outgoing traffic on ($bridge_name)"

    let reload_result = try {
        sudo ufw reload | complete
    } catch { { exit_code: 1 } }

    if $reload_result.exit_code != 0 {
        die "Failed to reload UFW configuration"
        return false
    }
    success "Reloaded UFW configuration"

    true
}

# Configure nftables
export def configure-nft [bridge_name: string]: nothing -> bool {
    if not (has-cmd nft) {
        info "nft not available, skipping nftables configuration"
        return true
    }

    info $"Configuring nftables for bridge: ($bridge_name)"

    # Check if filter table exists
    let table_exists = try {
        sudo nft list table ip filter | complete | get exit_code | $in == 0
    } catch { false }

    if not $table_exists {
        info "Creating filter table in nftables"
        let create_result = try {
            sudo nft add table ip filter | complete
        } catch { { exit_code: 1 } }

        if $create_result.exit_code != 0 {
            die "Failed to create filter table"
            return false
        }
        success "Created filter table"
    }

    # Check if DOCKER-USER chain exists
    let chain_exists = try {
        sudo nft list chain ip filter DOCKER-USER | complete | get exit_code | $in == 0
    } catch { false }

    if not $chain_exists {
        info "Creating DOCKER-USER chain in nftables"
        let create_chain = try {
            sudo nft add chain ip filter DOCKER-USER | complete
        } catch { { exit_code: 1 } }

        if $create_chain.exit_code != 0 {
            die "Failed to create DOCKER-USER chain"
            return false
        }
        success "Created DOCKER-USER chain"
    }

    # Add rule for incoming traffic
    let in_rule = try {
        sudo nft insert rule ip filter DOCKER-USER iifname $bridge_name counter accept | complete
    } catch { { exit_code: 1 } }

    if $in_rule.exit_code != 0 {
        die $"Failed to add rule for incoming traffic from ($bridge_name)"
        return false
    }
    success $"Added rule to accept incoming traffic from ($bridge_name)"

    # Add rule for related/established traffic
    let out_rule = try {
        sudo nft insert rule ip filter DOCKER-USER oifname $bridge_name ct state related,established counter accept | complete
    } catch { { exit_code: 1 } }

    if $out_rule.exit_code != 0 {
        die $"Failed to add rule for related/established traffic to ($bridge_name)"
        return false
    }
    success $"Added rule to accept related/established traffic to ($bridge_name)"

    true
}

# Configure IPv4 forwarding
export def configure-ipv4-forwarding [subnet: string]: nothing -> bool {
    info $"Configuring IPv4 forwarding for subnet: ($subnet)"

    let current_forwarding = try {
        open /proc/sys/net/ipv4/ip_forward | str trim
    } catch { "0" }

    if $current_forwarding == "1" {
        info "IPv4 forwarding is already enabled"
    } else {
        info "Enabling IPv4 forwarding..."
        let enable_result = try {
            sudo sysctl -w net.ipv4.ip_forward=1 | complete
        } catch { { exit_code: 1 } }

        if $enable_result.exit_code != 0 {
            die "Failed to enable IPv4 forwarding"
            return false
        }
        success "IPv4 forwarding enabled successfully"
    }

    # Persist configuration
    let config_file = "/etc/sysctl.d/99-incus-ipforward.conf"
    let already_persisted = try {
        ($config_file | path exists) and (open $config_file | str contains "net.ipv4.ip_forward=1")
    } catch { false }

    if $already_persisted {
        info "IPv4 forwarding configuration already persisted"
    } else {
        info "Persisting IPv4 forwarding configuration..."
        "net.ipv4.ip_forward=1" | sudo tee $config_file | ignore
        success "IPv4 forwarding configuration persisted"
    }

    true
}

# Configure iptables
export def configure-iptables [subnet: string]: nothing -> bool {
    if not (has-cmd iptables) {
        info "iptables not available, skipping iptables configuration"
        return true
    }

    info $"Configuring iptables rules for subnet: ($subnet)"

    # Check MASQUERADE rule
    let masq_exists = try {
        sudo iptables -t nat -S POSTROUTING | str contains $"POSTROUTING -s ($subnet) -j MASQUERADE"
    } catch { false }

    if $masq_exists {
        info $"MASQUERADE rule for ($subnet) already exists"
    } else {
        info $"Adding new MASQUERADE rule for ($subnet)..."
        let add_result = try {
            sudo iptables -t nat -A POSTROUTING -s $subnet -j MASQUERADE | complete
        } catch { { exit_code: 1 } }

        if $add_result.exit_code != 0 {
            die "Failed to add MASQUERADE rule"
            return false
        }
        success "Added new MASQUERADE rule"
    }

    # Check FORWARD policy
    let current_policy = try {
        sudo iptables -L FORWARD | lines | first | parse "policy {policy}" | get 0?.policy? | default ""
    } catch { "" }

    if $current_policy == "ACCEPT" {
        info "FORWARD policy is already set to ACCEPT"
    } else {
        info "Setting iptables FORWARD policy to ACCEPT..."
        let set_result = try {
            sudo iptables -P FORWARD ACCEPT | complete
        } catch { { exit_code: 1 } }

        if $set_result.exit_code != 0 {
            die "Failed to set FORWARD policy"
            return false
        }
        success "FORWARD policy set to ACCEPT"
    }

    true
}

# Main command
export def main [
    subnet?: string      # Network subnet in CIDR notation (e.g., 10.105.245.0/24)
    bridge?: string      # Bridge name (default: incusbr0)
    --help (-h)         # Show help
] {
    let use_subnet = $subnet | default $DEFAULT_SUBNET
    let bridge_name = $bridge | default "incusbr0"

    if not (validate-subnet $use_subnet) {
        die $"Invalid subnet format. Expected CIDR notation (e.g., ($DEFAULT_SUBNET))"
    }

    info $"Using subnet: ($use_subnet)"
    info $"Using bridge: ($bridge_name)"

    if not (check-prerequisites) {
        exit 1
    }

    if not (configure-ipv4-forwarding $use_subnet) {
        die "Failed to configure IPv4 forwarding"
    }

    if not (configure-firewalld $bridge_name) {
        die "Failed to configure firewalld"
    }

    if not (configure-ufw $bridge_name) {
        die "Failed to configure UFW"
    }

    if not (configure-nft $bridge_name) {
        die "Failed to configure nftables"
    }

    if not (configure-iptables $use_subnet) {
        die "Failed to configure iptables rules"
    }

    success $"Incus networking configured for subnet ($use_subnet) with bridge ($bridge_name). Containers should now have internet access."
}

