#!/usr/bin/env nu

use share/utils.nu *
use share/vm-utils.nu *
use share/vt-utils.nu *
use share/tmux-utils.nu *

const SESSION_NAME = "VME"

def vme-all-usage []: nothing -> nothing {
    print "Usage: vme-all [OPTION] [args...]

Perform batch operations on all libvirt VME VMs.

Options:
    create           Create all VME VMs (default if no option)
    start            Start all VME VMs
    stop             Stop all VME VMs
    restart          Restart all VME VMs
    delete           Delete all VME VMs
    exec <cmd...>    Execute a command in all VME VMs
    tmux             Create tmux session with SSH connections to all VME VMs
    --help           Display this help message

Examples:
    vme-all              # Create VMs for various Linux distributions
    vme-all create       # Create all VMs
    vme-all start        # Start all VMs
    vme-all stop         # Stop all VMs
    vme-all restart      # Restart all VMs
    vme-all delete       # Delete all VMs
    vme-all exec 'uptime' # Run command in each VM
    vme-all tmux         # Open tmux session with all running VMs"
}

# Create VME VMs for each distro in DISTRO_LIST_VME, skipping existing ones
def vme-all-create []: nothing -> nothing {
    slog "Creating libvirt VMs..."

    for distro in $DISTRO_LIST_VME {
        let vm_name = $"($distro)-vme"
        if (vm-exists $vm_name) {
            warn $"($distro) VM already exists, skipping..."
        } else {
            do { ^vme-create --distro $distro --name $vm_name } | complete | ignore
            sleep 2sec
        }
    }

    success "All VMs created successfully!"
    slog "You can access them using: virsh console <vm-name>"
}

# Perform an operation on every VM in DISTRO_LIST_VME (distro-vme naming convention)
def vme-all-op [op: string, ...args: string]: nothing -> nothing {
    slog $"Performing operation '($op)' on all VMs..."

    for distro in $DISTRO_LIST_VME {
        let vm_name = $"($distro)-vme"
        if not (vm-exists $vm_name) {
            warn $"VM ($vm_name) does not exist, skipping..."
            continue
        }

        match $op {
            "start" => {
                if (vm-running $vm_name) {
                    slog $"VM '($vm_name)' is already running"
                } else {
                    ^virsh --connect qemu:///system start $vm_name
                    wait-for-ip $vm_name { |vm| vm-exists $vm } { |vm| vm-running $vm } { |vm| vm-ip $vm }
                }
            }
            "stop" | "shutdown" => {
                if not (vm-running $vm_name) {
                    slog $"VM '($vm_name)' is not running"
                } else {
                    ^virsh --connect qemu:///system shutdown $vm_name
                }
            }
            "restart" | "reboot" => {
                if not (vm-running $vm_name) {
                    ^virsh --connect qemu:///system start $vm_name
                } else {
                    ^virsh --connect qemu:///system reboot $vm_name
                }
            }
            "delete" | "rm" => {
                if (vm-running $vm_name) {
                    warn $"VM '($vm_name)' is running, stopping..."
                    try { ^virsh --connect qemu:///system destroy $vm_name }
                }
                try { ^virsh --connect qemu:///system snapshot-delete $vm_name --current --metadata }
                try { ^virsh --connect qemu:///system destroy $vm_name }
                try { ^virsh --connect qemu:///system undefine $vm_name }
            }
            "exec" => {
                if ($args | is-empty) {
                    fail "Command required for exec. Usage: vme-all exec <command>"
                    return
                }
                let ip = (vm-ip $vm_name)
                if ($ip | is-empty) {
                    warn $"Cannot exec on ($vm_name): no IP address"
                } else {
                    let command = ($args | str join " ")
                    slog $"Executing on ($vm_name) ($ip): ($command)"
                    do {
                        ^ssh
                            -o StrictHostKeyChecking=no
                            -o UserKnownHostsFile=/dev/null
                            -o ConnectTimeout=15
                            -o LogLevel=ERROR
                            $"($env.USER)@($ip)"
                            $command
                    } | complete | ignore
                }
            }
            _ => { warn $"Unsupported operation: ($op)" }
        }
    }

    success $"Performed operation '($op)' on all VMs successfully!"
}

# Create a tmux grid session with SSH connections to all running VME VMs
def vme-all-tmux []: nothing -> nothing {
    let vm_names = ($DISTRO_LIST_VME | each { |d| $"($d)-vme" })
    let running = ($vm_names | where { |vm| vm-running $vm })

    if ($running | is-empty) {
        fail "No VME VMs are currently running."
        return
    }

    let ssh_cmds = ($running | each { |vm| $"vme ssh ($vm) ($env.USER)" })
    tmux-grid $SESSION_NAME ...$ssh_cmds
}

# Main dispatcher for vme-all batch operations
def main [op?: string, ...args: string]: nothing -> nothing {
    let operation = ($op | default "")

    if (($operation == "--help") or ($operation == "help") or ($operation == "-h")) {
        vme-all-usage
        return
    }

    virt-check-prerequisites

    if (($operation | is-empty) or ($operation == "create")) {
        vme-all-create
        return
    }

    match $operation {
        "start" | "stop" | "shutdown" | "restart" | "reboot" | "delete" | "rm" | "exec" => {
            vme-all-op $operation ...$args
        }
        "tmux" => { vme-all-tmux }
        _ => {
            fail $"Unknown option: ($operation)"
            vme-all-usage
        }
    }
}
