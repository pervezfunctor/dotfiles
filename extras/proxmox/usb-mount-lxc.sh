#!/bin/bash

set -euo pipefail

# Check for required commands
for cmd in lsblk pct mountpoint; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: Required command '$cmd' not found."
    exit 1
  fi
done

choose_from_list() {
  local -n arr="$1"

  if [ "${#arr[@]}" -eq 0 ]; then
    echo "No options available."
    return 1
  fi

  local i
  for i in "${!arr[@]}"; do
    echo "[$i] ${arr[$i]}"
  done

  local choice
  while true; do
    read -r -p "Select number: " choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 0 ] && [ "$choice" -lt "${#arr[@]}" ]; then
      echo "${arr[$choice]}"
      return 0
    else
      echo "Invalid selection."
    fi
  done
}

# List USB block devices
mapfile -t usb_devices < <(lsblk -lno NAME,TRAN | awk '$2 == "usb" {print "/dev/" $1}')
if [ "${#usb_devices[@]}" -eq 0 ]; then
  echo "⚠️ No USB devices found."
  exit 1
fi

echo "Available USB devices:"
for i in "${!usb_devices[@]}"; do
  echo "[$i] ${usb_devices[$i]}"
done

read -r -p "Select USB device number: " usb_index
if ! [[ "$usb_index" =~ ^[0-9]+$ ]] || [ "$usb_index" -ge "${#usb_devices[@]}" ]; then
  echo "Invalid selection."
  exit 1
fi
selected_usb="${usb_devices[$usb_index]}"

# List LXC containers
mapfile -t containers < <(pct list | awk 'NR>1 {print $1}')
if [ "${#containers[@]}" -eq 0 ]; then
  echo "⚠️ No LXC containers found."
  exit 1
fi

echo "Available LXC containers:"
for i in "${!containers[@]}"; do
  echo "[$i] ${containers[$i]}"
done

read -r -p "Select LXC container number: " ct_index
if ! [[ "$ct_index" =~ ^[0-9]+$ ]] || [ "$ct_index" -ge "${#containers[@]}" ]; then
  echo "Invalid selection."
  exit 1
fi
selected_ctid="${containers[$ct_index]}"

# Ask for container mount path
read -r -p "Enter container mount path (e.g., /mnt/usb): " ct_mount
if [ -z "$ct_mount" ]; then
  echo "No mount path specified."
  exit 1
fi

# Set host mount point
host_mount="/mnt/usb_${selected_usb#/dev/}"

# Mount USB on host if not already mounted
if ! mountpoint -q "$host_mount"; then
  sudo mkdir -p "$host_mount"
  sudo mount "$selected_usb" "$host_mount"
fi

# Find next available mp index
conf_file="/etc/pve/lxc/${selected_ctid}.conf"
if [ ! -f "$conf_file" ]; then
  echo "LXC config file not found: $conf_file"
  exit 1
fi

mapfile -t mp_indices < <(grep -oP '^mp\K\d+(?=:)' "$conf_file" || true)
if [ "${#mp_indices[@]}" -eq 0 ]; then
  next_mp=0
else
  max_index=$(printf '%s\n' "${mp_indices[@]}" | sort -n | tail -1)
  next_mp=$((max_index + 1))
fi

# Add mount point to container config
echo "mp${next_mp}: $host_mount,mp=$ct_mount" | sudo tee -a "$conf_file" >/dev/null

echo "✅ Success! $selected_usb mounted to CT $selected_ctid at $ct_mount"
