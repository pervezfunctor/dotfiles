#!/bin/bash

# Creates groups: backup, vm-admin, vm-user with default users
# Creates admin user with sudo privileges

# Ensure script runs as root
if [ "$(id -u)" -ne 0 ]; then
  echo "Script must be run as root. Use sudo." >&2
  exit 1
fi

# Create groups
declare -a groups=("backup" "vm-admin" "vm-user")
for group in "${groups[@]}"; do
  if ! getent group "$group" >/dev/null; then
    groupadd "$group"
    echo "Created group: $group"
  else
    echo "Group $group already exists. Skipping."
  fi
done

# Create default users for each group
declare -A users=(
  ["backup"]="pve-backup"
  ["vm-admin"]="pve-vm-admin"
  ["vm-user"]="pve-vm"
)

for group in "${!users[@]}"; do
  username="${users[$group]}"
  if ! id "$username" &>/dev/null; then
    useradd -m -s /bin/bash -G "$group" "$username"
    password=$(openssl rand -base64 12 | tr -d '/+=\n')
    echo "$username:$password" | chpasswd
    echo "Created $username (Group:$group) | Password: $password"
  else
    echo "User $username already exists. Skipping."
  fi
done

# Create admin user with sudo privileges
admin_user="pve-admin"
if ! id "$admin_user" &>/dev/null; then
  useradd -m -s /bin/bash "$admin_user"
  usermod -aG sudo "$admin_user"
  admin_pass=$(openssl rand -base64 12 | tr -d '/+=\n')
  echo "$admin_user:$admin_pass" | chpasswd
  echo "Created admin user: $admin_user | Password: $admin_pass"
  echo "Sudo privileges granted to $admin_user via 'sudo' group"
else
  echo "Admin user $admin_user already exists. Skipping."
fi

echo "Setup complete. Note: Proxmox-specific permissions must be configured separately via web interface."
