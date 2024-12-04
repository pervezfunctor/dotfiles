#! /usr/bin/env bash

# Exit on errors
set -e

PROXMOX_STORAGE="local-lvm"   # Storage target for Proxmox
VM_ID=9000                    # Unique ID for the new VM
VM_NAME="ubuntu-template"     # Name for the VM
# UBUNTU_IMAGE_URL="https://cloud-images.ubuntu.com/minimal/releases/noble/release/ubuntu-24.04-minimal-cloudimg-amd64.img"
UBUNTU_IMAGE_URL="https://cloud-images.ubuntu.com/minimal/releases/oracular/release/ubuntu-24.10-minimal-cloudimg-amd64.img"
DISK_SIZE="20G"               # Size of the VM disk
MEMORY="8192"                 # VM memory in MB
CORES="4"                     # Number of CPU cores
USERNAME="pervez"             # Username for cloud-init
PASSWORD="program"            # Password for cloud-init

# Download the Ubuntu image
echo "Downloading Ubuntu image..."
wget -O /tmp/ubuntu-cloud.img "$UBUNTU_IMAGE_URL"

# Convert the image to Proxmox-compatible format
echo "Converting image to qcow2 format..."
qemu-img convert -f qcow2 /tmp/ubuntu-cloud.img /tmp/ubuntu-cloud.qcow2

# Create a new VM
echo "Creating VM $VM_NAME with ID $VM_ID..."
qm create $VM_ID --name $VM_NAME --memory $MEMORY --cores $CORES --net0 virtio,bridge=vmbr0

# Import the disk to Proxmox storage
echo "Importing disk to Proxmox storage..."
qm importdisk $VM_ID /tmp/ubuntu-cloud.qcow2 $PROXMOX_STORAGE

# Attach the disk to the VM
echo "Attaching disk to VM..."
qm set $VM_ID --scsihw virtio-scsi-pci --scsi0 $PROXMOX_STORAGE:vm-$VM_ID-disk-0

# Resize the disk if necessary
echo "Resizing disk to $DISK_SIZE..."
qm resize $VM_ID scsi0 $DISK_SIZE

# Set the boot disk
echo "Configuring boot options..."
qm set $VM_ID --boot c --bootdisk scsi0

# Add cloud-init drive
echo "Adding cloud-init drive..."
qm set $VM_ID --ide2 $PROXMOX_STORAGE:cloudinit

# Set the VM to use cloud-init for networking and SSH keys
echo "Configuring cloud-init..."
qm set $VM_ID --serial0 socket --vga serial0 --cipassword $PASSWORD --ciuser $USERNAME

# Convert the VM to a template
echo "Converting VM to template..."
qm template $VM_ID

# Clean up temporary files
echo "Cleaning up..."
rm -f /tmp/ubuntu-cloud.img /tmp/ubuntu-cloud.qcow2

echo "Ubuntu template $VM_NAME created successfully."
