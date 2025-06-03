#!/bin/bash
# Bash completion for vm-create script
# shellcheck disable=SC2207  # Standard pattern for bash completions

_vm_create_get_distros() {
    echo "ubuntu fedora arch debian"
}

_vm_create_get_dotfiles_groups() {
    echo "min slim-shell shell dev box"
}

_vm_create_completion() {
    local cur prev opts
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD - 1]}"

    # All vm-create options
    opts="--distro --name --memory --vcpus --disk-size --ssh-key --bridge --username --release --docker --brew --dotfiles --password --help -h"

    case "$prev" in
    --distro)
        COMPREPLY=($(compgen -W "$(_vm_create_get_distros)" -- "$cur"))
        return 0
        ;;
    --dotfiles)
        COMPREPLY=($(compgen -W "$(_vm_create_get_dotfiles_groups)" -- "$cur"))
        return 0
        ;;
    --name)
        # VM name - no specific completion, user provides custom name
        return 0
        ;;
    --memory)
        # Memory in MB - provide some common values
        COMPREPLY=($(compgen -W "1024 2048 4096 8192 16384" -- "$cur"))
        return 0
        ;;
    --vcpus)
        # Number of vCPUs - provide common values
        COMPREPLY=($(compgen -W "1 2 4 8" -- "$cur"))
        return 0
        ;;
    --disk-size)
        # Disk size - provide common values
        COMPREPLY=($(compgen -W "20G 40G 80G 100G" -- "$cur"))
        return 0
        ;;
    --ssh-key)
        # SSH key path - complete file paths
        COMPREPLY=($(compgen -f -- "$cur"))
        return 0
        ;;
    --bridge)
        # Network bridge - provide common bridge names
        COMPREPLY=($(compgen -W "virbr0 br0" -- "$cur"))
        return 0
        ;;
    --username)
        # Username - no specific completion
        return 0
        ;;
    --release)
        # Distribution release - depends on distro, provide common ones
        COMPREPLY=($(compgen -W "noble jammy focal bullseye bookworm current latest" -- "$cur"))
        return 0
        ;;
    --password)
        # Password - no completion for security
        return 0
        ;;
    *)
        # Complete with available options
        COMPREPLY=($(compgen -W "$opts" -- "$cur"))
        return 0
        ;;
    esac
}

# Register the completion function
complete -F _vm_create_completion vm-create
