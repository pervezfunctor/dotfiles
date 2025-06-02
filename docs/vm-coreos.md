# Fedora CoreOS VM Creation Script

The `vm-coreos` script allows you to easily create Fedora CoreOS virtual machines using KVM/QEMU and Ignition configuration.

## Overview

Fedora CoreOS is a container-focused operating system that uses Ignition for initial configuration instead of cloud-init. This script automates the process of:

- Downloading Fedora CoreOS images
- Generating Ignition configuration from Butane configs
- Creating and launching VMs with proper Ignition setup
- Supporting multiple CoreOS streams (stable, testing, next)

## Prerequisites

### Install Required Packages

**Fedora:**
```bash
sudo dnf install qemu-kvm libvirt virt-install coreos-installer butane
```

**Ubuntu/Debian:**
```bash
sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients virtinst jq
# For Butane, use container or download binary
```

**Arch Linux:**
```bash
sudo pacman -S qemu-desktop libvirt virt-install
# For coreos-installer and butane, use AUR or containers
```

### Setup

1. **Start libvirt service:**
   ```bash
   sudo systemctl start libvirtd
   sudo systemctl enable libvirtd
   ```

2. **Add user to libvirt group:**
   ```bash
   sudo usermod -a -G libvirt $USER
   # Log out and back in for group changes to take effect
   ```

3. **Generate SSH key (if not already done):**
   ```bash
   ssh-keygen -t ed25519 -C "your_email@example.com"
   ```

## Usage

### Basic Usage

```bash
# Create basic CoreOS VM
./bin/vm-coreos --name coreos-test

# Create development VM with more resources
./bin/vm-coreos --name coreos-dev --memory 4096 --vcpus 4

# Create VM with k3s Kubernetes cluster
./bin/vm-coreos --name coreos-k3s --k3s --memory 4096

# Create VM with custom Ignition config
./bin/vm-coreos --name coreos-custom --ignition my-config.ign
```

### All Options

```bash
./bin/vm-coreos --name VM_NAME [OPTIONS]

REQUIRED:
    --name NAME         VM name

OPTIONS:
    --memory MB         RAM in MB (default: 2048)
    --vcpus NUM         Number of vCPUs (default: 2)
    --disk-size GB      Disk size in GB (default: 20)
    --ssh-key PATH      SSH public key path (default: auto-detected)
    --bridge BRIDGE     Network bridge (default: virbr0)
    --stream STREAM     CoreOS stream: stable|testing|next (default: stable)
    --hostname HOST     VM hostname (default: VM_NAME)
    --ignition PATH     Custom Ignition config file (optional)
    --no-download       Use existing image, don't download
    --force-download    Force re-download even if image exists
    --k3s               Install k3s Kubernetes cluster
```

## CoreOS Streams

- **stable**: Most reliable, recommended for production
- **testing**: Pre-release testing, more recent packages
- **next**: Development stream, latest features

## Features

- **Automatic image download** using coreos-installer or direct download
- **Ignition configuration generation** from Butane configs
- **SSH key injection** for the default user (`core`)
- **k3s Kubernetes installation** option for single-node clusters
- **Custom Ignition configs** support
- **Multiple stream support** (stable, testing, next)
- **Architecture detection** (x86_64, aarch64, s390x, ppc64le)
- **SELinux compatibility** with proper file labeling
- **Robust container support** for Butane conversion (stdin + volume mount fallback)

## VM Management

### Common Commands

```bash
# List all VMs
virsh list --all

# Start VM
virsh start VM_NAME

# Stop VM gracefully
virsh shutdown VM_NAME

# Force stop VM
virsh destroy VM_NAME

# Delete VM
virsh undefine VM_NAME

# Get VM IP address
virsh domifaddr VM_NAME

# Console access
virsh console VM_NAME
```

### SSH Access

After VM creation (wait 2-3 minutes for Ignition to complete):

```bash
# SSH by name (if added to /etc/hosts)
ssh coreos@vm_name

# SSH by IP
ssh coreos@VM_IP
```

## CoreOS-Specific Commands

```bash
# Update system
rpm-ostree upgrade

# Install packages
rpm-ostree install <package>

# Reboot to apply changes
systemctl reboot

# Check system status
rpm-ostree status

# Rollback to previous version
rpm-ostree rollback
```

## Container Management

CoreOS comes with Podman pre-installed:

```bash
# Run container
podman run <image>

# List containers
podman ps

# List images
podman images

# Pull image
podman pull <image>
```

## k3s Kubernetes

When using the `--k3s` flag, the VM will have a single-node k3s Kubernetes cluster installed:

**What gets installed:**
- k3s server (single-node cluster)
- kubectl configured for the user
- Kubeconfig at `~/.kube/config`
- k3s service enabled and started

**Usage:**
```bash
# Create k3s VM
./bin/vm-coreos --name k3s-cluster --k3s --memory 4096

# After VM is ready (5-6 minutes total)
ssh core@k3s-cluster

# Check cluster status
kubectl get nodes
kubectl get pods -A

# Deploy a simple app
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=NodePort

# Get service info
kubectl get svc
```

**k3s Commands:**
```bash
# Cluster management
kubectl cluster-info
kubectl get nodes
kubectl get pods -A
kubectl get svc -A

# Application deployment
kubectl apply -f manifest.yaml
kubectl create deployment <name> --image=<image>
kubectl expose deployment <name> --port=<port>

# Troubleshooting
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl exec -it <pod-name> -- /bin/sh

# Service management
sudo systemctl status k3s
sudo systemctl restart k3s
```

## Custom Ignition Configuration

If you need custom configuration beyond what the script provides, create a Butane config:

```yaml
# example.bu
variant: fcos
version: 1.6.0
passwd:
  users:
    - name: core
      ssh_authorized_keys:
        - ssh-rsa AAAA...
      groups:
        - wheel
        - sudo
storage:
  files:
    - path: /etc/hostname
      mode: 0644
      contents:
        inline: my-coreos-vm
systemd:
  units:
    - name: my-service.service
      enabled: true
      contents: |
        [Unit]
        Description=My Custom Service

        [Service]
        ExecStart=/usr/bin/echo "Hello CoreOS"

        [Install]
        WantedBy=multi-user.target
```

Convert to Ignition and use:

```bash
# Convert Butane to Ignition
butane --pretty --strict example.bu > example.ign

# Use with vm-coreos
./bin/vm-coreos --name my-vm --ignition example.ign
```

## Troubleshooting

### Common Issues

1. **libvirtd not running:**
   ```bash
   sudo systemctl start libvirtd
   ```

2. **Permission denied:**
   ```bash
   sudo usermod -a -G libvirt $USER
   # Log out and back in
   ```

3. **coreos-installer not found:**
   ```bash
   # Use container method or install jq for direct download
   sudo dnf install jq
   ```

4. **Butane conversion permission denied:**
   ```bash
   # If using podman/docker and getting permission errors:
   # The script will automatically try stdin method first
   # If that fails, check SELinux context:
   sudo setsebool -P container_manage_cgroup true
   ```

5. **Image decompression fails (file exists):**
   ```bash
   # If you get "File exists" error during decompression:
   ./bin/vm-coreos --name my-vm --force-download
   # Or manually remove the files:
   sudo rm -f /var/lib/libvirt/images/vm-name-coreos/fedora-coreos-*.qcow2*
   ```

6. **VM already exists:**
   ```bash
   virsh destroy VM_NAME
   virsh undefine VM_NAME
   ```

### Setup Time Expectations

- **Basic VM:** 2-3 minutes for Ignition completion
- **With k3s:** 5-6 minutes (includes k3s installation and setup)

### Logs and Debugging

- Check VM console: `virsh console VM_NAME`
- Check Ignition logs: `journalctl -u ignition-*`
- Check rpm-ostree status: `rpm-ostree status`

## Differences from vm-create

Unlike the unified `vm-create` script, `vm-coreos` is specifically designed for Fedora CoreOS:

- Uses **Ignition** instead of cloud-init
- Uses **Butane** configs instead of YAML
- Supports **CoreOS streams** (stable/testing/next)
- Uses **rpm-ostree** for package management
- Includes **Podman** by default
- Supports **immutable OS** concepts

## Examples

```bash
# Basic development environment
./bin/vm-coreos --name coreos-dev --memory 4096 --vcpus 4

# k3s Kubernetes cluster
./bin/vm-coreos --name k3s-cluster --k3s --memory 4096 --vcpus 2

# Testing stream VM
./bin/vm-coreos --name coreos-testing --stream testing

# Custom hostname and bridge
./bin/vm-coreos --name coreos-server --hostname my-server --bridge br0

# Use existing image (no download)
./bin/vm-coreos --name coreos-quick --no-download

# Force re-download image (useful if previous download was corrupted)
./bin/vm-coreos --name coreos-fresh --force-download
```
