#!/bin/bash

set -euo pipefail

# Check for required commands
for cmd in gum lsblk pct; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: Required command '$cmd' not found."
    exit 1
  fi
done

# List USB block devices
mapfile -t usb_devices < <(lsblk -lno NAME,TRAN | awk '$2 == "usb" {print "/dev/" $1}')
if [ "${#usb_devices[@]}" -eq 0 ]; then
  echo "⚠️ No USB devices found."
  exit 1
fi

# Select USB device
selected_usb=$(printf '%s\n' "${usb_devices[@]}" | gum choose --header="Select USB Device")
if [ -z "$selected_usb" ]; then
  echo "No USB device selected."
  exit 1
fi

# List LXC containers
mapfile -t containers < <(pct list | awk 'NR>1 {print $1}')
if [ "${#containers[@]}" -eq 0 ]; then
  echo "⚠️ No LXC containers found."
  exit 1
fi

# Select container
selected_ctid=$(printf '%s\n' "${containers[@]}" | gum choose --header="Select LXC Container")
if [ -z "$selected_ctid" ]; then
  echo "No container selected."
  exit 1
fi

# Ask for container mount path
ct_mount=$(gum input --placeholder="Container mount path (e.g., /mnt/usb)")
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
mapfile -t mp_indices < <(grep -oP '^mp\K\d+(?=:)' "$conf_file" || true)
if [ "${#mp_indices[@]}" -eq 0 ]; then
  next_mp=0
else
  max_index=$(printf '%s\n' "${mp_indices[@]}" | sort -n | tail -1)
  next_mp=$((max_index + 1))
fi

# Add mount point to container config
echo "mp${next_mp}: $host_mount,mp=$ct_mount" | sudo tee -a "$conf_file" >/dev/null

echo "✅ Success! $selected_usb mounted to CT$selected_ctid at $ct_mount"

# ask and restart container
read -rp "🔄 Restart container $selected_ctid now to apply changes? (y/n): " RESTART
if [[ "$RESTART" =~ ^[Yy]$ ]]; then
  sudo pct restart "$selected_ctid"
  echo "✅ Container restarted. USB is now available at $ct_mount"
else
  echo "✅ USB mount added. Restart container manually to use it."
fi
