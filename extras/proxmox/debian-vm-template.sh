#!/bin/bash

set -e

PROXMOX_STORAGE="local-lvm"
VM_ID=9100
VM_NAME="debian-template"
DEBIAN_IMAGE_URL="https://cdimage.debian.org/cdimage/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
DISK_SIZE="32G"
MEMORY="8192"
CORES="4"
USERNAME="pervez"
PASSWORD="program"

usage() {
    echo "Usage: $0 -i VM_ID -n VM_NAME -s STORAGE -u DEBIAN_IMAGE_URL [--disk-size DISK_SIZE] [--memory MEMORY] [--cores CORES] [--username USERNAME] [--password PASSWORD]"
    echo
    echo "Options:"

    echo "  -s, --storage STORAGE           Proxmox storage target (e.g., local-lvm)"
    echo "  -i, --vm-id VM_ID               Unique ID for the new VM"
    echo "  -n, --vm-name VM_NAME           Name for the VM"
    echo "  -d, --disk-size DISK_SIZE       Size of the VM disk (default: 20G)"
    echo "  -m, --memory MEMORY             VM memory in MB (default: 2048)"
    echo "  -c, --cores CORES               Number of CPU cores (default: 4)"
    echo "  -u, --username USERNAME         Username for cloud-init (default: pervez)"
    echo "  -p, --password PASSWORD         Password for cloud-init (default: program)"
    echo "  -U, --url DEBIAN_IMAGE_URL      URL of the Debian cloud image"
    echo "  -h, --help                      Display this help message"
    exit 1
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -s|--storage) STORAGE="$2"; shift ;;
        -i|--vm-id) VM_ID="$2"; shift ;;
        -n|--vm-name) VM_NAME="$2"; shift ;;
        -d|--disk-size) DISK_SIZE="$2"; shift ;;
        -m|--memory) MEMORY="$2"; shift ;;
        -c|--cores) CORES="$2"; shift ;;
        -u|--username) USERNAME="$2"; shift ;;
        -p|--password) PASSWORD="$2"; shift ;;
        -U|--url) DEBIAN_IMAGE_URL="$2"; shift ;;
        -h|--help) usage ;;
        *) echo "Unknown parameter: $1"; usage ;;
    esac
    shift
done

CUR_DIR=$(dirname "$0")

# Read options from options file, from the same directory as the script
if [ -f "$CUR_DIR/options" ]; then
    source "$CUR_DIR/options"
fi

echo "Downloading Debian image..."

if ! [ -f /tmp/debian-cloud.qcow2 ]; then
    wget -O /tmp/debian-cloud.qcow2 "$DEBIAN_IMAGE_URL"
fi

if [ $? -ne 0 ] || [ ! -f /tmp/debian-cloud.qcow2 ]; then
  echo "Failed to download Debian image."
  exit 1
fi

echo "Creating VM $VM_NAME with ID $VM_ID..."
qm create $VM_ID  --name $VM_NAME \
                  --memory $MEMORY \
                  --cores $CORES \
                  --ostype l26 \
                  --agent 1 \
                  --cpu host \
                  --net0 virtio,bridge=vmbr0

if [ $? -ne 0 ]; then
  echo "Failed to create VM."
  exit 1
fi

echo "Importing disk to Proxmox storage..."
qm importdisk $VM_ID /tmp/debian-cloud.qcow2 $PROXMOX_STORAGE

if [ $? -ne 0 ]; then
  echo "Failed to import disk."
  exit 1
fi

echo "Attaching disk to VM..."
qm set $VM_ID --scsihw virtio-scsi-pci \
              --scsi0 $PROXMOX_STORAGE:vm-$VM_ID-disk-0,discard=on,ssd=1

if [ $? -ne 0 ]; then
  echo "Failed to attach disk."
  exit 1
fi

echo "Resizing disk to $DISK_SIZE..."
qm resize $VM_ID scsi0 $DISK_SIZE

if [ $? -ne 0 ]; then
  echo "Failed to resize disk."
  exit 1
fi

echo "Configuring boot options..."
qm set $VM_ID --boot c --bootdisk scsi0

if [ $? -ne 0 ]; then
  echo "Failed to set boot disk."
  exit 1
fi

echo "Adding cloud-init drive..."
qm set $VM_ID --ide2 $PROXMOX_STORAGE:cloudinit

if [ $? -ne 0 ]; then
  echo "Failed to add cloud-init drive."
  exit 1
fi

echo "Configuring cloud-init..."
qm set $VM_ID --serial0 socket \
              --vga serial0 \
              --ipconfig0 ip=dhcp \
              --cipassword $PASSWORD \
              --ciuser $USERNAME

if [ $? -ne 0 ]; then
  echo "Failed to configure cloud-init."
  exit 1
fi

echo "Converting VM to template..."
qm template $VM_ID

if [ $? -ne 0 ]; then
  echo "Failed to convert VM to template."
  exit 1
fi

echo "Debian template $VM_NAME created successfully."
