#!/bin/bash

# Variables (customize as needed)
VMID=110 # Unique container ID
HOSTNAME="ubuntu-lxc"
PASSWORD="your_root_password"
TEMPLATE_STORAGE="local"   # Storage name for templates (e.g., 'local')
ROOTFS_STORAGE="local-lvm" # Storage for rootfs (e.g., 'local-lvm')
DISK_SIZE="8G"
MEMORY="1024"
CPUS="2"
NET_BRIDGE="vmbr0"
SCRIPT_TO_RUN="/root/your-script.sh" # Path to the script on the Proxmox host

# Ubuntu template version (adjust as needed)
UBUNTU_TEMPLATE="ubuntu-22.04-standard_22.04-1_amd64.tar.zst"

# Download Ubuntu template if not present
if ! pveam list $TEMPLATE_STORAGE | grep -q "$UBUNTU_TEMPLATE"; then
  echo "Downloading Ubuntu LXC template..."
  pveam update
  pveam download $TEMPLATE_STORAGE $UBUNTU_TEMPLATE
fi

# Create the container
pct create $VMID /var/lib/vz/template/cache/$UBUNTU_TEMPLATE \
  --hostname $HOSTNAME \
  --password $PASSWORD \
  --storage $ROOTFS_STORAGE \
  --rootfs ${ROOTFS_STORAGE}:${DISK_SIZE} \
  --memory $MEMORY \
  --cores $CPUS \
  --net0 name=eth0,bridge=$NET_BRIDGE,ip=dhcp \
  --unprivileged 1 \
  --start 1

# Wait a moment to ensure container is up
sleep 5

# Copy the script into the container
pct push $VMID $SCRIPT_TO_RUN /root/$(basename $SCRIPT_TO_RUN) -perms 755

# Run the script inside the container
pct exec $VMID -- bash /root/$(basename $SCRIPT_TO_RUN)

echo "Script execution inside LXC container complete."
