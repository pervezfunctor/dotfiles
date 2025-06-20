# !/usr/bin/env bash
# Bash completion for ivm script
# shellcheck disable=SC2207  # Standard pattern for bash completions

_incus_vm_get_vms() {
    if command -v incus >/dev/null 2>&1; then
        incus list --format csv --columns n 2>/dev/null | grep -v '^$'
    fi
}

_incus_vm_get_distros() {
    echo "ubuntu fedora arch debian centos alpine nixos"
}

_incus_vm_get_snapshots() {
    local vm_name="$1"
    if command -v incus >/dev/null 2>&1 && [[ -n "$vm_name" ]]; then
        incus info "$vm_name" 2>/dev/null | grep -A 100 "Snapshots:" | grep "^  " | awk '{print $1}' | grep -v "^$"
    fi
}

_incus_vm_completion() {
    local cur vm_commands
    cur="${COMP_WORDS[COMP_CWORD]}"

    # Available ivm commands
    vm_commands="install list status create start stop restart delete console exec ip ssh info config snapshot restore copy cleanup"

    # If we're completing the first argument (command)
    if [[ $COMP_CWORD -eq 1 ]]; then
        COMPREPLY=($(compgen -W "$vm_commands" -- "$cur"))
        return 0
    fi

    # Get the command (first argument)
    local command="${COMP_WORDS[1]}"

    case "$command" in
    create)
        # For 'ivm create', second argument is distro, third is optional name
        if [[ $COMP_CWORD -eq 2 ]]; then
            COMPREPLY=($(compgen -W "$(_incus_vm_get_distros)" -- "$cur"))
            return 0
        elif [[ $COMP_CWORD -eq 3 ]]; then
            # VM name - no specific completion
            return 0
        fi
        ;;
    status | start | stop | restart | delete | console | ip | info | config)
        # These commands require a VM name
        if [[ $COMP_CWORD -eq 2 ]]; then
            COMPREPLY=($(compgen -W "$(_incus_vm_get_vms)" -- "$cur"))
            return 0
        fi
        ;;
    exec)
        # exec requires VM name, then command
        if [[ $COMP_CWORD -eq 2 ]]; then
            COMPREPLY=($(compgen -W "$(_incus_vm_get_vms)" -- "$cur"))
            return 0
        elif [[ $COMP_CWORD -ge 3 ]]; then
            # Command completion - basic commands
            COMPREPLY=($(compgen -c -- "$cur"))
            return 0
        fi
        ;;
    ssh)
        # ssh requires VM name, optional username
        if [[ $COMP_CWORD -eq 2 ]]; then
            COMPREPLY=($(compgen -W "$(_incus_vm_get_vms)" -- "$cur"))
            return 0
        elif [[ $COMP_CWORD -eq 3 ]]; then
            # Username - no specific completion
            return 0
        fi
        ;;
    snapshot)
        # snapshot requires VM name, optional snapshot name
        if [[ $COMP_CWORD -eq 2 ]]; then
            COMPREPLY=($(compgen -W "$(_incus_vm_get_vms)" -- "$cur"))
            return 0
        elif [[ $COMP_CWORD -eq 3 ]]; then
            # Snapshot name - no specific completion
            return 0
        fi
        ;;
    restore)
        # restore requires VM name, then snapshot name
        if [[ $COMP_CWORD -eq 2 ]]; then
            COMPREPLY=($(compgen -W "$(_incus_vm_get_vms)" -- "$cur"))
            return 0
        elif [[ $COMP_CWORD -eq 3 ]]; then
            # Get snapshots for the specified VM
            local vm_name="${COMP_WORDS[2]}"
            COMPREPLY=($(compgen -W "$(_incus_vm_get_snapshots "$vm_name")" -- "$cur"))
            return 0
        fi
        ;;
    copy)
        # copy requires source VM name, then destination name
        if [[ $COMP_CWORD -eq 2 ]]; then
            COMPREPLY=($(compgen -W "$(_incus_vm_get_vms)" -- "$cur"))
            return 0
        elif [[ $COMP_CWORD -eq 3 ]]; then
            # Destination name - no specific completion
            return 0
        fi
        ;;
    install | list | cleanup)
        # These commands don't take additional arguments
        return 0
        ;;
    *)
        return 0
        ;;
    esac
}

# Register the completion function
complete -F _incus_vm_completion ivm
