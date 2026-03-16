#!/usr/bin/env nu

use share/utils.nu *
use share/vm-utils.nu *
use share/vt-utils.nu *
use share/tmux-utils.nu *

const SESSION_NAME = "VME"

# Print usage information
def vme-usage []: nothing -> nothing {
    print "Usage: vme <command> [vm-name...]

Manage VMs created with vme-create script.

COMMANDS:
    list                List all VMs
    create  ARGS        Create a new VM (same args as vme-create)
    create-all ARGS     Create multiple VMs, select from fzf menu
    all <op> [args...]  Perform operation on all VMs
    tmux                Select VMs and create tmux grid session
    autostart <vm>      Set VM to start on boot
    start [vm...]       Start VM(s)
    shutdown [vm...]    Gracefully stop VM(s)
    restart [vm...]     Restart VM(s)
    kill [vm...]        Force stop VM(s)
    delete [vm...]      Delete VM(s) completely
    console <vm>        Connect to VM console
    ip <vm>             Show VM IP address
    is-running <vm>     Check if VM is running
    info <vm>           Show VM status and info
    logs <vm>           Show cloud-init logs
    disk <vm>           Show VM disk usage
    ssh <vm> [user]     SSH into VM (auto-detects user if omitted)
    exec <vm> <cmd...>  Execute command in VM via SSH
    cmd <virsh-args>    Run virsh command with qemu:///system connection
    net <command>       Manage libvirt virtual networks
    start-libvirt       Start the libvirtd service

EXAMPLES:
    vme list
    vme ip debian
    vme is-running debian
    vme create --distro debian
    vme start debian
    vme start debian fedora
    vme start
    vme delete old-vm
    vme ssh debian
    vme exec debian 'ls -la'"
}

# Check prerequisites for VME commands
def vme-check-prerequisites []: nothing -> nothing {
    vm-check-cmds virsh
    if not (has-cmd virt-cat) {
        warn "virt-cat not available, some commands won't work"
    }
}

# List all VMs via virsh
def vme-list-all []: nothing -> nothing {
    ^virsh --connect qemu:///system list --all
}

# Show disk block devices for a VM
def vme-disk [vm_name: string]: nothing -> nothing {
    ^virsh --connect qemu:///system domblklist $vm_name
}

# Show detailed info for a VM
def vme-status [vm_name: string]: nothing -> nothing {
    ^virsh --connect qemu:///system dominfo $vm_name
}

# Enable autostart for a VM
def vme-autostart [vm_name: string]: nothing -> nothing {
    ^virsh --connect qemu:///system autostart $vm_name
}

# Start a VM and wait for it to acquire an IP
def vme-start [vm_name: string]: nothing -> nothing {
    if (vm-running $vm_name) {
        slog $"VM '($vm_name)' is already running"
        return
    }
    ^virsh --connect qemu:///system start $vm_name
    wait-for-ip $vm_name { |vm| vm-exists $vm } { |vm| vm-running $vm } { |vm| vm-ip $vm }
}

# Gracefully shut down a VM
def vme-stop [vm_name: string]: nothing -> nothing {
    if not (vm-running $vm_name) {
        slog $"VM '($vm_name)' is not running"
        return
    }
    ^virsh --connect qemu:///system shutdown $vm_name
}

# Restart a VM (start if not running, reboot otherwise)
def vme-restart [vm_name: string]: nothing -> nothing {
    if not (vm-running $vm_name) {
        vme-start $vm_name
    } else {
        ^virsh --connect qemu:///system reboot $vm_name
    }
}

# Force-stop (destroy) a VM
def vme-force-stop [vm_name: string]: nothing -> nothing {
    if not (vm-running $vm_name) {
        slog $"VM '($vm_name)' is not running"
    } else {
        ^virsh --connect qemu:///system destroy $vm_name
    }
}

# Delete a VM and optionally its disk directory
def vme-delete [vm_name: string]: nothing -> nothing {
    if (vm-running $vm_name) {
        warn $"VM '($vm_name)' is running, stopping..."
        vme-force-stop $vm_name
    }

    let domblklist = (do { ^virsh --connect qemu:///system domblklist $vm_name } | complete)
    let vda = if $domblklist.exit_code == 0 {
        $domblklist.stdout
            | lines
            | where { |l| $l | str contains "vda" }
            | first?
            | default ""
            | split words
            | get 1?
            | default ""
    } else { "" }

    try { ^virsh --connect qemu:///system snapshot-delete $vm_name --current --metadata }
    try { ^virsh --connect qemu:///system destroy $vm_name }
    try { ^virsh --connect qemu:///system undefine $vm_name }

    if ($vda | is-not-empty) {
        let dir = ($vda | path dirname)
        slog $"Found vm directory: ($dir)"
        let response = (input "Delete dir? (y/N): " | str trim | str downcase)
        if $response == "y" {
            warn $"Deleting ($dir)"
            ^sudo rm -rf $dir
        }
    }
}

# Show cloud-init logs for a VM
def vme-logs [vm_name: string]: nothing -> nothing {
    if not (vm-exists $vm_name) {
        fail $"VM '($vm_name)' does not exist"
        return
    }
    ^sudo virt-cat -d $vm_name /var/log/cloud-init.log
}

# Connect to a VM's serial console
def vme-console [vm_name: string]: nothing -> nothing {
    if not (vm-running $vm_name) {
        fail $"VM '($vm_name)' is not running"
        return
    }
    ^virsh --connect qemu:///system console $vm_name
}

# SSH into a VM, starting it first if needed
def vme-do-ssh [vm_name: string, username: string = ""]: nothing -> nothing {
    let user = if ($username | is-empty) { $env.USER } else { $username }

    if not (vm-running $vm_name) {
        vme-start $vm_name
    }

    let ip = (vm-ip $vm_name)
    if ($ip | is-empty) {
        fail $"Could not determine IP for VM '($vm_name)'"
        return
    }

    exec ssh -o ConnectTimeout=15 -o ConnectionAttempts=1 $"($user)@($ip)"
}

# Execute a command inside a VM via SSH
def vme-do-exec [vm_name: string, ...cmd: string]: nothing -> nothing {
    if ($cmd | is-empty) {
        fail "Error: Command required for exec"
        info "Usage: vme exec <vm-name> <command>"
        return
    }

    if not (vm-running $vm_name) {
        vme-start $vm_name
    }

    let ip = (vm-ip $vm_name)
    if ($ip | is-empty) {
        fail $"Could not determine IP for VM '($vm_name)'"
        return
    }

    let command = ($cmd | str join " ")
    ^ssh
        -o StrictHostKeyChecking=no
        -o UserKnownHostsFile=/dev/null
        -o ConnectTimeout=15
        -o ConnectionAttempts=1
        -o LogLevel=ERROR
        $"($env.USER)@($ip)"
        $command
}

# Run a raw virsh command with qemu:///system connection
def vme-cmd [...args: string]: nothing -> nothing {
    ^virsh --connect qemu:///system ...$args
}

# Manage libvirt virtual networks
def vme-net [command?: string, ...args: string]: nothing -> nothing {
    let cmd = ($command | default "")
    if ($cmd | is-empty) {
        print "Usage: vme net <list|info|start|auto-start|stop|delete> [network-name]"
        return
    }
    match $cmd {
        "ls" | "list" => { ^virsh --connect qemu:///system net-list --all }
        "info" => { ^virsh --connect qemu:///system net-info ...$args }
        "start" => { ^virsh --connect qemu:///system net-start ...$args }
        "auto-start" => { ^virsh --connect qemu:///system net-autostart ...$args }
        "stop" => { ^virsh --connect qemu:///system net-destroy ...$args }
        "rm" | "delete" => {
            try { ^virsh --connect qemu:///system net-destroy ...$args }
            ^virsh --connect qemu:///system net-undefine ...$args
        }
        _ => {
            fail $"Unknown net command: ($cmd)"
            print "Usage: vme net <list|info|start|auto-start|stop|delete> [network-name]"
        }
    }
}

# Interactively select VMs and create a tmux grid session with SSH connections
def vme-select-session []: nothing -> nothing {
    let vms = (get-vm-list)
    if ($vms | is-empty) {
        fail "No VMs found. Please create VMs first."
        return
    }

    let selected = (select-multi "Select VMs to connect to:" ...$vms)
    if ($selected | is-empty) {
        slog "No VMs selected."
        return
    }

    let ssh_cmds = ($selected | each { |vm| $"vme ssh ($vm) ($env.USER)" })
    tmux-grid $SESSION_NAME ...$ssh_cmds
}

# Perform an operation on all known VME VMs (distro-vme naming convention)
def vme-all-op [op: string, ...args: string]: nothing -> nothing {
    slog $"Performing operation '($op)' on all VMs..."

    for distro in $DISTRO_LIST_VME {
        let vm_name = $"($distro)-vme"
        if (vm-exists $vm_name) {
            match $op {
                "start" | "boot" => { vme-start $vm_name }
                "stop" | "shutdown" => { vme-stop $vm_name }
                "restart" | "reboot" => { vme-restart $vm_name }
                "delete" | "rm" => { vme-delete $vm_name }
                "kill" | "destroy" | "force-stop" => { vme-force-stop $vm_name }
                _ => { warn $"Unsupported all operation: ($op)" }
            }
        } else {
            warn $"VM ($vm_name) does not exist, skipping..."
        }
    }

    success $"Performed operation '($op)' on all VMs successfully!"
}

# Interactively select distros and create VME VMs (distro-vme) for each
def vme-create-all [...args: string]: nothing -> nothing {
    let distros = (select-distributions ...$DISTRO_LIST_VME)
    if ($distros | is-empty) {
        slog "No distributions selected."
        return
    }

    create-all-vt { |distro|
        let vm_name = $"($distro)-vme"
        if (vm-exists $vm_name) {
            warn $"($distro) VM already exists, skipping..."
            true
        } else {
            let result = (do { ^vme-create --distro $distro --name $vm_name ...$args } | complete)
            $result.exit_code == 0
        }
    } $distros
}

# Main command dispatcher for vme (libvirt VM management)
def main [command?: string, ...args: string]: nothing -> nothing {
    let cmd = ($command | default "")
    if (($cmd | is-empty) or ($cmd == "--help") or ($cmd == "-h")) {
        vme-usage
        return
    }

    if $cmd != "start-libvirt" {
        vme-check-prerequisites
    }

    let vm_name = ($args | first? | default "")

    match $cmd {
        "list" | "ls" => { vme-list-all }
        "create" | "new" => { ^vme-create ...$args }
        "create-all" => { vme-create-all ...$args }
        "all" => { vme-all-op ...$args }
        "tmux" => { vme-select-session }
        "start-libvirt" => { ^sudo systemctl start libvirtd }
        "cmd" => { vme-cmd ...$args }
        "net" => { vme-net ...$args }
        "autostart" => {
            handle-multiple-arguments { get-vm-list } { |vm| vme-autostart $vm } ...$args
        }
        "start" | "boot" => {
            handle-multiple-arguments { get-vm-list } { |vm| vme-start $vm } ...$args
        }
        "stop" | "shutdown" => {
            handle-multiple-arguments { get-vm-list } { |vm| vme-stop $vm } ...$args
        }
        "restart" | "reboot" => {
            handle-multiple-arguments { get-vm-list } { |vm| vme-restart $vm } ...$args
        }
        "destroy" | "kill" | "force-stop" => {
            handle-multiple-arguments { get-vm-list } { |vm| vme-force-stop $vm } ...$args
        }
        "delete" | "rm" => {
            handle-multiple-arguments { get-vm-list } { |vm| vme-delete $vm } ...$args
        }
        "console" => {
            handle-one-argument { get-vm-list } { |vm| vme-console $vm } $vm_name
        }
        "ip" => {
            handle-one-argument { get-vm-list } { |vm| vm-ip $vm | print } $vm_name
        }
        "is-running" => {
            handle-one-argument { get-vm-list } { |vm| vm-running $vm | print } $vm_name
        }
        "info" | "status" => {
            handle-one-argument { get-vm-list } { |vm| vme-status $vm } $vm_name
        }
        "disk" => {
            handle-one-argument { get-vm-list } { |vm| vme-disk $vm } $vm_name
        }
        "logs" => {
            handle-one-argument { get-vm-list } { |vm| vme-logs $vm } $vm_name
        }
        "ssh" => {
            let user = ($args | get 1? | default "")
            handle-one-argument { get-vm-list } { |vm| vme-do-ssh $vm $user } $vm_name
        }
        "exec" => {
            vme-do-exec $vm_name ...($args | skip 1)
        }
        _ => {
            fail $"Unknown command: ($cmd)"
            vme-usage
        }
    }
}
