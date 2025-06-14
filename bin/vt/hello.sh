#!/usr/bin/env bash

create_commands() {
  if [ "$#" -lt 3 ]; then
    echo "Usage: create_commands <output_array_name> <prefix> <distro1> ..." >&2
    return 1
  fi

  local -n cmds_ref
  cmds_ref="$1"
  local cmd_prefix="$2"
  shift 2

  local -a distro_list=("$@")

  cmds_ref=()

  for distro in "${distro_list[@]}"; do
    cmds_ref+=("${cmd_prefix} ssh ${distro}-${cmd_prefix}")
  done
}

main() {

  vms_to_use=("ubuntu2204" "fedora36" "debian11")
  my_ssh_commands=() # The array we want the function to populate

  create_commands my_ssh_commands "vm" "${vms_to_use[@]}"

  echo "The following commands were generated:"
  printf "  - %s\n" "${my_ssh_commands[@]}"

}

main
