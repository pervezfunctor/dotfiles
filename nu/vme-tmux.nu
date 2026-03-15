#!/usr/bin/env nu

use share/utils.nu *
use share/vm-utils.nu *
use share/vt-utils.nu *
use share/tmux-utils.nu *

const SESSION_NAME = "VME"

def vme-tmux-usage []: nothing -> nothing {
    print "Usage: vme-tmux [OPTION]

Manage a tmux session with SSH connections to libvirt VMs.

Options:
  create    Create a new tmux session with SSH connections to VMs (default)
  attach    Attach to an existing session
  detach    Detach from the current session
  destroy   Kill the tmux session
  --help    Display this help message

Examples:
  vme-tmux           # Create session (recreates if exists)
  vme-tmux create    # Force create a new session
  vme-tmux attach    # Attach to existing session
  vme-tmux detach    # Detach from current session
  vme-tmux destroy   # Kill the session"
}

# Create (or recreate) a tmux grid session with SSH connections to VME VMs.
# If vms is empty, uses DISTRO_LIST_VME; otherwise uses the provided distro names.
def vme-create-session [...vms: string]: nothing -> nothing {
    let distros = if ($vms | is-empty) { $DISTRO_LIST_VME } else { $vms }

    tmux-session $SESSION_NAME --force

    slog $"Creating tmux session '($SESSION_NAME)' with SSH connections to libvirt VMs..."

    let vm_names = (generate-names "vme" ...$distros)

    let ssh_cmds = (create-commands-generic { |vm| $"vme ssh ($vm) ($env.USER)" } ...$vm_names)

    start-sessions { |vm| vm-running $vm } { |vm|
        let result = (do { ^virsh --connect qemu:///system start $vm } | complete)
        $result.exit_code == 0
    } ...$vm_names

    tmux-grid $SESSION_NAME ...$ssh_cmds
}

# Main dispatcher for vme-tmux session management
def main [command?: string]: nothing -> nothing {
    let cmd = ($command | default "")

    virt-check-prerequisites

    if not (has-cmd tmux) {
        fail "tmux is not installed. Please install it first."
        return
    }

    match $cmd {
        "create" | "" | "-c" | "--create" => { vme-create-session }
        "attach" => { attach-session $SESSION_NAME }
        "detach" => { detach-session }
        "destroy" => { destroy-session $SESSION_NAME }
        "--help" | "help" | "-h" => { vme-tmux-usage }
        _ => {
            fail $"Unknown option: ($cmd)"
            vme-tmux-usage
        }
    }
}
