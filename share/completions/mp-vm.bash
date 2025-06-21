#!/usr/bin/env bash
# Bash completion for mvm script
# shellcheck disable=SC2207  # Standard pattern for bash completions

_multipass_vm_get_vms() {
    if command -v multipass >/dev/null 2>&1; then
        multipass list --format csv 2>/dev/null | tail -n +2 | cut -d',' -f1 | grep -v '^$'
    fi
}

_multipass_vm_get_distros() {
    echo "ubuntu lts jammy noble oracular plucky"
}

_multipass_vm() {
    local cur prev words cword
    _init_completion || return

    local commands="install list status create start stop restart delete shell exec ip ssh info mount umount"

    case $cword in
    1)
        COMPREPLY=($(compgen -W "$commands" -- "$cur"))
        ;;
    2)
        case $prev in
        create)
            COMPREPLY=($(compgen -W "$(_multipass_vm_get_distros)" -- "$cur"))
            ;;
        status | start | stop | restart | delete | shell | exec | ip | ssh | info | mount | umount)
            COMPREPLY=($(compgen -W "$(_multipass_vm_get_vms)" -- "$cur"))
            ;;
        esac
        ;;
    3)
        case ${words[1]} in
        create)
            # VM name for create command
            ;;
        exec)
            # Command to execute - no completion
            ;;
        ssh)
            # Username for SSH - ubuntu is primary for Multipass
            COMPREPLY=($(compgen -W "ubuntu" -- "$cur"))
            ;;
        mount)
            # Source path for mount
            _filedir -d
            ;;
        umount)
            # Mount path for umount - no specific completion
            ;;
        esac
        ;;
    4)
        case ${words[1]} in
        mount)
            # Target path for mount - no specific completion
            ;;
        esac
        ;;
    esac
}

complete -F _multipass_vm mvm
