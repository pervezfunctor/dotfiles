#!/bin/bash
# Bash completion for ict script
# shellcheck disable=SC2207  # Standard pattern for bash completions

_incus_ct_get_containers() {
    if command -v incus >/dev/null 2>&1; then
        incus list --format csv --columns n 2>/dev/null | grep -v '^$'
    fi
}

_incus_ct_get_distros() {
    echo "ubuntu fedora arch debian centos alpine nixos"
}

_incus_ct_get_snapshots() {
    local container_name="$1"
    if command -v incus >/dev/null 2>&1 && [[ -n "$container_name" ]]; then
        incus info "$container_name" 2>/dev/null | grep -A 100 "Snapshots:" | grep "^  " | awk '{print $1}' | grep -v "^$"
    fi
}

_incus_ct_completion() {
    local cur ct_commands
    cur="${COMP_WORDS[COMP_CWORD]}"

    # Available ict commands
    ct_commands="install list status create start stop restart delete shell exec ip ssh info config snapshot restore copy cleanup"

    # If we're completing the first argument (command)
    if [[ $COMP_CWORD -eq 1 ]]; then
        COMPREPLY=($(compgen -W "$ct_commands" -- "$cur"))
        return 0
    fi

    # Get the command (first argument)
    local command="${COMP_WORDS[1]}"

    case "$command" in
    create)
        # For 'ict create', second argument is distro, third is optional name
        if [[ $COMP_CWORD -eq 2 ]]; then
            COMPREPLY=($(compgen -W "$(_incus_ct_get_distros)" -- "$cur"))
            return 0
        elif [[ $COMP_CWORD -eq 3 ]]; then
            # Container name - no specific completion
            return 0
        fi
        ;;
    status | start | stop | restart | delete | shell | ip | info | config)
        # These commands require a container name
        if [[ $COMP_CWORD -eq 2 ]]; then
            COMPREPLY=($(compgen -W "$(_incus_ct_get_containers)" -- "$cur"))
            return 0
        fi
        ;;
    exec)
        # exec requires container name, then command
        if [[ $COMP_CWORD -eq 2 ]]; then
            COMPREPLY=($(compgen -W "$(_incus_ct_get_containers)" -- "$cur"))
            return 0
        elif [[ $COMP_CWORD -ge 3 ]]; then
            # Command completion - basic commands
            COMPREPLY=($(compgen -c -- "$cur"))
            return 0
        fi
        ;;
    ssh)
        # ssh requires container name, optional username
        if [[ $COMP_CWORD -eq 2 ]]; then
            COMPREPLY=($(compgen -W "$(_incus_ct_get_containers)" -- "$cur"))
            return 0
        elif [[ $COMP_CWORD -eq 3 ]]; then
            # Username - no specific completion
            return 0
        fi
        ;;
    snapshot)
        # snapshot requires container name, optional snapshot name
        if [[ $COMP_CWORD -eq 2 ]]; then
            COMPREPLY=($(compgen -W "$(_incus_ct_get_containers)" -- "$cur"))
            return 0
        elif [[ $COMP_CWORD -eq 3 ]]; then
            # Snapshot name - no specific completion
            return 0
        fi
        ;;
    restore)
        # restore requires container name, then snapshot name
        if [[ $COMP_CWORD -eq 2 ]]; then
            COMPREPLY=($(compgen -W "$(_incus_ct_get_containers)" -- "$cur"))
            return 0
        elif [[ $COMP_CWORD -eq 3 ]]; then
            # Get snapshots for the specified container
            local container_name="${COMP_WORDS[2]}"
            COMPREPLY=($(compgen -W "$(_incus_ct_get_snapshots "$container_name")" -- "$cur"))
            return 0
        fi
        ;;
    copy)
        # copy requires source container name, then destination name
        if [[ $COMP_CWORD -eq 2 ]]; then
            COMPREPLY=($(compgen -W "$(_incus_ct_get_containers)" -- "$cur"))
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
complete -F _incus_ct_completion ict
