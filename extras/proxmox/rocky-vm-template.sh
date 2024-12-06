#!/bin/bash

set -e

# Default values
PROXMOX_STORAGE="local-lvm"
VM_ID=9300
VM_NAME="rocky-linux-template"
ROCKY_IMAGE_URL="https://dl.rockylinux.org/pub/rocky/9.5/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2"
DISK_SIZE="20G"
RAM_SIZE="8192"
CPU_CORES="4"
USERNAME="pervez"
PASSWORD="program"


CUR_DIR=$(dirname "$0")

# Read options from options file, from the same directory as the script
if [ -f "$CUR_DIR/options" ]; then
    source "$CUR_DIR/options"
fi

echo "Downloading Rocky Linux image..."

if ! [ -f /tmp/rocky-cloud.qcow2 ]; then
  rm -f /tmp/rocky-cloud.qcow2
    wget -O /tmp/rocky-cloud.qcow2 "$ROCKY_IMAGE_URL"
fi

# Create the VM
echo "Creating VM $VM_NAME with ID $VM_ID..."
qm create "$VM_ID" \
    --name "$VM_NAME" \
    --memory "$RAM_SIZE" \
    --cores "$CPU_CORES" \
    --net0 "virtio,bridge=vmbr0"

if [ $? -ne 0 ]; then
    echo "Failed to create VM $VM_NAME with ID $VM_ID"
    exit 1
fi

echo "Importing disk to Proxmox storage..."
qm importdisk $VM_ID /tmp/rocky-cloud.qcow2 $PROXMOX_STORAGE

if [ $? -ne 0 ]; then
    echo "Failed to import disk to Proxmox storage"
    exit 1
fi

echo "Attaching disk to VM..."
qm set "$VM_ID" --scsihw virtio-scsi-pci --scsi0 "$PROXMOX_STORAGE:vm-$VM_ID-disk-0"

if [ $? -ne 0 ]; then
    echo "Failed to attach disk to VM"
    exit 1
fi

# Resize the disk if necessary
echo "Resizing disk to $DISK_SIZE..."
qm resize $VM_ID scsi0 $DISK_SIZE

if [ $? -ne 0 ]; then
    echo "Failed to resize disk to $DISK_SIZE"
    exit 1
fi

# Set the boot disk
echo "Configuring boot options..."
qm set $VM_ID --boot c --bootdisk scsi0

if [ $? -ne 0 ]; then
    echo "Failed to configure boot options"
    exit 1
fi

# Enable cloud-init
echo "Configuring cloud-init..."
qm set  $VM_ID --serial0 socket --vga serial0 --ipconfig0 ip=dhcp --cipassword $PASSWORD --ciuser $USERNAME --agent enabled=1


if [ $? -ne 0 ]; then
    echo "Failed to configure cloud-init"
    exit 1
fi

# Convert the VM to a template
echo "Converting VM to template..."
qm template $VM_ID

if [ $? -ne 0 ]; then
    echo "Failed to convert VM to template"
    exit 1
fi

# Clean up temporary files
echo "Cleaning up..."
rm -f /tmp/rocky-cloud.qcow2

echo "Rocky Linux template $VM_NAME created successfully."

