#!/usr/bin/env bash
# Bash completion for vm-create script
# shellcheck disable=SC2034

_vm_create_completions() {
    local cur prev words cword
    _init_completion || return

    # Available distributions
    local distros="ubuntu fedora arch debian alpine tumbleweed opensuse tw"

    # Options that require a value
    local value_options="--distro --name --memory --vcpus --disk-size --ssh-key --bridge --username --password"

    # Boolean flags
    local flag_options="--docker --brew --nix --help -h"

    # Special option that must be last
    local last_option="--dotfiles"

  case $prev in
  --distro)
      mapfile -t COMPREPLY < <(compgen -W "$distros" -- "$cur")
      return
      ;;
  --name)
      # Suggest VM names based on distributions
      mapfile -t COMPREPLY < <(compgen -W "$distros myvm vm-1 test-vm dev-vm" -- "$cur")
      return
      ;;
  --memory)
      # Common memory sizes in MB
      mapfile -t COMPREPLY < <(compgen -W "1024 2048 4096 8192 12288 16384" -- "$cur")
      return
      ;;
  --vcpus)
      # Common vCPU counts
      mapfile -t COMPREPLY < <(compgen -W "1 2 4 6 8 12 16" -- "$cur")
      return
      ;;
  --disk-size)
      # Common disk sizes
      mapfile -t COMPREPLY < <(compgen -W "20G 40G 60G 80G 100G 120G" -- "$cur")
      return
      ;;
  --ssh-key)
    # Complete SSH public key files
    _filedir -d pub
    return
    ;;
  --bridge)
      # Common bridge interfaces
      mapfile -t COMPREPLY < <(compgen -W "virbr0 br0 bridge0 default" -- "$cur")
      return
      ;;
  --username)
      # Common usernames
      mapfile -t COMPREPLY < <(compgen -W "ubuntu user admin devops tester" -- "$cur")
      return
      ;;
  --password)
      # Don't suggest anything for passwords
      return
      ;;
  --dotfiles)
      # Suggest common dotfiles options
      mapfile -t COMPREPLY < <(compgen -W "shell shell-slim docker python code-server nvim zsh tmux" -- "$cur")
      return
      ;;
  esac

  # If we're not after a value option, suggest all options
  if [[ "$cur" == -* ]]; then
    # Check if --dotfiles is already in the command
    if [[ " ${words[*]} " =~ " --dotfiles " ]]; then
        # If --dotfiles is present, don't suggest it anymore
        mapfile -t COMPREPLY < <(compgen -W "$value_options $flag_options" -- "$cur")
    else
        mapfile -t COMPREPLY < <(compgen -W "$value_options $flag_options $last_option" -- "$cur")
    fi
else
    # Default to suggesting distributions if no dash
    mapfile -t COMPREPLY < <(compgen -W "$distros" -- "$cur")
fi
}

complete -F _vm_create_completions vm-create
