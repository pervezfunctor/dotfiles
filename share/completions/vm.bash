#!/usr/bin/env bash
# Bash completion for vm script
# shellcheck disable=SC2207  # Standard pattern for bash completions

_vm_get_vms() {
    if command -v virsh >/dev/null 2>&1; then
        virsh list --all --name 2>/dev/null | grep -v '^$'
    fi
}

_vm_get_distros() {
    echo "ubuntu fedora arch debian"
}

_vm_create_completion() {
    local cur prev opts
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD - 1]}"

    # vm-create options
    opts="--distro --name --memory --vcpus --disk-size --ssh-key --bridge --username --release --docker --brew --dotfiles --password --help -h"

    case "$prev" in
    --distro)
        COMPREPLY=($(compgen -W "$(_vm_get_distros)" -- "$cur"))
        return 0
        ;;
    --name | --memory | --vcpus | --disk-size | --ssh-key | --bridge | --username | --release | --dotfiles | --password)
        # These options require values but we can't predict them
        return 0
        ;;
    *)
        COMPREPLY=($(compgen -W "$opts" -- "$cur"))
        return 0
        ;;
    esac
}

_vm_completion() {
    local cur prev opts vm_commands
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD - 1]}"

    # Available vm commands
    vm_commands="install list status create autostart start stop restart destroy delete console ip logs cleanup ssh"

    # If we're completing the first argument (command)
    if [[ $COMP_CWORD -eq 1 ]]; then
        COMPREPLY=($(compgen -W "$vm_commands" -- "$cur"))
        return 0
    fi

    # Get the command (first argument)
    local command="${COMP_WORDS[1]}"

    case "$command" in
    create)
        # For 'vm create', use vm-create completion starting from position 2
        local create_words=("${COMP_WORDS[@]:2}")
        local create_cword=$((COMP_CWORD - 2))

        if [[ $create_cword -ge 0 ]]; then
            # Temporarily modify COMP_WORDS and COMP_CWORD for vm-create completion
            local old_words=("${COMP_WORDS[@]}")
            local old_cword=$COMP_CWORD

            COMP_WORDS=("vm-create" "${create_words[@]}")
            COMP_CWORD=$((create_cword + 1))

            _vm_create_completion

            # Restore original values
            COMP_WORDS=("${old_words[@]}")
            COMP_CWORD=$old_cword
        fi
        return 0
        ;;
    status | autostart | start | stop | restart | destroy | delete | console | ip | logs | ssh)
        # These commands require a VM name
        if [[ $COMP_CWORD -eq 2 ]]; then
            COMPREPLY=($(compgen -W "$(_vm_get_vms)" -- "$cur"))
            return 0
        elif [[ $command == "ssh" && $COMP_CWORD -eq 3 ]]; then
            # For ssh command, third argument can be username (no completion)
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
complete -F _vm_completion vm
