#!/bin/bash
# Bash completion for ivm-create script
# shellcheck disable=SC2207  # Standard pattern for bash completions

_incus_vm_create_get_distros() {
    echo "ubuntu fedora arch debian centos alpine nixos"
}

_incus_vm_create_completion() {
    local cur prev opts
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD - 1]}"

    # All ivm-create options
    opts="--distro --name --release --username --password --vcpus --ram --disk --ssh-key --bridge --help -h"

    case "$prev" in
    --distro)
        COMPREPLY=($(compgen -W "$(_incus_vm_create_get_distros)" -- "$cur"))
        return 0
        ;;
    --name | --username | --password)
        # These options require values but we can't predict them
        return 0
        ;;
    --release)
        # Distribution release - provide common ones
        COMPREPLY=($(compgen -W "24.04 22.04 20.04 42 41 40 current latest 12 11 9-Stream 8-Stream 3.19 3.18" -- "$cur"))
        return 0
        ;;
    --vcpus)
        # Number of vCPUs
        COMPREPLY=($(compgen -W "1 2 4 8 16" -- "$cur"))
        return 0
        ;;
    --ram)
        # RAM in MB
        COMPREPLY=($(compgen -W "1024 2048 4096 8192 16384" -- "$cur"))
        return 0
        ;;
    --disk)
        # Disk size
        COMPREPLY=($(compgen -W "10GB 20GB 40GB 80GB 100GB" -- "$cur"))
        return 0
        ;;
    --ssh-key)
        # SSH key file path
        COMPREPLY=($(compgen -f -- "$cur"))
        return 0
        ;;
    --bridge)
        # Network bridge - provide common bridge names
        COMPREPLY=($(compgen -W "incusbr0 br0 lxdbr0" -- "$cur"))
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
complete -F _incus_vm_create_completion ivm-create
