# VM Creation Script

The unified `vm-create` script allows you to easily create virtual machines for multiple Linux distributions using KVM/QEMU and cloud-init.

## Supported Distributions

- **Ubuntu** (noble, jammy, focal)
- **Fedora** (40, 41, 42)
- **Arch Linux** (latest)
- **Debian** (bookworm, bullseye, trixie)

## Prerequisites

### Install Required Packages

**Ubuntu/Debian:**
```bash
sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients virtinst qemu-utils wget genisoimage
```

**Fedora:**
```bash
sudo dnf install qemu-kvm libvirt virt-install qemu-img wget genisoimage
```

**Arch Linux:**
```bash
sudo pacman -S qemu-desktop libvirt virt-install qemu-img wget cdrtools
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
# Create Ubuntu VM with defaults
./bin/vm-create --distro ubuntu

# Create Fedora VM with custom name and memory
./bin/vm-create --distro fedora --name myvm --memory 8192

# Create Arch VM with larger disk
./bin/vm-create --distro arch --disk-size 80G --vcpus 4

# Create Debian 11 VM
./bin/vm-create --distro debian --release bullseye

# Create Ubuntu VM with Docker pre-installed
./bin/vm-create --distro ubuntu --docker

# Create Ubuntu VM with Homebrew and development tools
./bin/vm-create --distro ubuntu --brew

# Create Fedora VM with both Docker and Homebrew
./bin/vm-create --distro fedora --docker --brew
```

### All Options

```bash
./bin/vm-create --distro DISTRO [OPTIONS]

REQUIRED:
    --distro DISTRO     Distribution (ubuntu|fedora|arch|debian)

OPTIONS:
    --name NAME         VM name (default: distribution name)
    --memory MB         RAM in MB (default: 4096)
    --vcpus NUM         Number of vCPUs (default: 4)
    --disk-size SIZE    Disk size (default: 40G)
    --ssh-key PATH      SSH public key path (auto-detected)
    --bridge BRIDGE     Network bridge (default: virbr0)
    --username USER     VM username (default: distribution-specific)
    --release REL       Distribution release (default: latest stable)
    --docker            Install Docker in the VM
    --brew              Install Homebrew and essential development tools
```

## Distribution-Specific Defaults

| Distribution | Default Release | Default Username | User Groups |
| ------------ | --------------- | ---------------- | ----------- |
| Ubuntu       | noble (24.04)   | ubuntu           | sudo        |
| Fedora       | 42              | fedora           | wheel       |
| Arch Linux   | latest          | arch             | wheel       |
| Debian       | bookworm (12)   | debian           | sudo        |

## Pre-installed Software Options

### Docker Installation (`--docker`)

When using the `--docker` flag, the VM will have Docker pre-installed and configured:

- **Docker Engine** - Latest stable version
- **Docker Compose** - Latest version
- **User permissions** - VM user added to docker group
- **Service enabled** - Docker service starts automatically

**Usage:**
```bash
./bin/vm-create --distro ubuntu --docker
```

**Available commands after VM creation:**
```bash
docker --version
docker compose version
docker run hello-world
```

### Homebrew Installation (`--brew`)

When using the `--brew` flag, the VM will have Homebrew and essential development tools pre-installed:

**Homebrew Package Manager:**
- Latest Homebrew installation
- Configured for Linux environment
- Added to shell environment (`.bashrc` and `.profile`)

**Pre-installed Development Tools:**
- **Core tools:** git, curl, wget, vim, htop
- **Shell utilities:** starship, fzf, ripgrep, eza, zoxide, fd, bat
- **Development tools:** gum, tmux, lazygit, git-delta, just, jq, yq
- **Build dependencies:** gcc, make, build-essential (distribution-specific)

**Usage:**
```bash
./bin/vm-create --distro ubuntu --brew
```

**Available commands after VM creation:**
```bash
brew --version
brew list
brew search <package>
brew install <package>
brew update && brew upgrade
```

### Combined Installation

Both options can be used together for a complete development environment:

```bash
./bin/vm-create --distro fedora --docker --brew --name dev-vm
```

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

After VM creation (wait 2-3 minutes for cloud-init to complete):

```bash
# Using the vm script (recommended - auto-detects username)
./bin/vm ssh vm_name

# Manual SSH by name (if added to /etc/hosts)
ssh username@vm_name

# Manual SSH by IP
ssh username@VM_IP
```

**Username Auto-Detection:**
The `vm ssh` command automatically detects the correct username based on the VM name:
- **CoreOS VMs**: Uses `coreos` user
- **Fedora VMs**: Uses `fedora` user
- **Debian VMs**: Uses `debian` user
- **Arch VMs**: Uses `arch` user
- **Other VMs**: Defaults to `ubuntu` user

You can override the username: `./bin/vm ssh vm_name custom_user`

## Features

- **Unified interface** for multiple distributions
- **Cloud-init integration** for automated setup
- **Distribution-specific optimizations**
- **Automatic SSH key injection**
- **Smart SSH access** with username auto-detection
- **Network bridge support**
- **Customizable VM specifications**
- **Pre-installed software options:**
  - **Docker** - Container platform with Docker Compose
  - **Homebrew** - Package manager with development tools
- **Error handling and cleanup**
- **Comprehensive logging**
- **Cross-distribution compatibility**

## Migration from Individual Scripts

The unified script replaces the individual `vm-ubuntu`, `vm-fedora`, `vm-arch`, and `vm-debian` scripts. All functionality has been preserved and enhanced with new features:

```bash
# Old way
./bin/vm-ubuntu --name myvm --memory 8192

# New way (basic)
./bin/vm-create --distro ubuntu --name myvm --memory 8192

# New way (with enhanced features)
./bin/vm-create --distro ubuntu --name myvm --memory 8192 --docker --brew
```

**New capabilities not available in individual scripts:**
- Pre-installed Docker with Docker Compose
- Pre-installed Homebrew with development tools
- Cross-distribution consistency
- Enhanced error handling and logging

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

3. **Network bridge not found:**
   - Script will automatically fall back to default libvirt network
   - Or specify `--bridge default` explicitly

4. **VM already exists:**
   ```bash
   virsh destroy VM_NAME
   virsh undefine VM_NAME
   ```

### Logs and Debugging

- Check VM console: `virsh console VM_NAME`
- Check cloud-init status: `ssh user@vm` then `cloud-init status`
- Check setup completion: Look for `/home/username/vm-setup-complete` file

### Setup Time Expectations

- **Basic VM:** 2-3 minutes for cloud-init completion
- **With Docker:** 4-6 minutes (includes Docker installation)
- **With Homebrew:** 5-8 minutes (includes Homebrew and tools installation)
- **With both Docker and Homebrew:** 8-12 minutes

**Note:** Homebrew installation includes compiling some packages, which may take longer on systems with limited CPU/memory.

## Advanced Usage

### Custom Network Bridge

```bash
# Create custom bridge
sudo ip link add br0 type bridge
sudo ip link set br0 up

# Use custom bridge
./bin/vm-create --distro ubuntu --bridge br0
```

### Multiple VMs

```bash
# Create multiple VMs with different names
./bin/vm-create --distro ubuntu --name web-server
./bin/vm-create --distro fedora --name dev-box
./bin/vm-create --distro arch --name test-env
```

### Development Environment Setup

```bash
# Full development environment with Docker and Homebrew
./bin/vm-create --distro ubuntu --name dev-env --memory 8192 --vcpus 4 --docker --brew

# Lightweight development VM with just Homebrew tools
./bin/vm-create --distro arch --name code-vm --brew

# Container-focused VM with Docker
./bin/vm-create --distro fedora --name container-vm --docker --memory 6144
```

### Distribution-Specific Examples

```bash
# Ubuntu development server
./bin/vm-create --distro ubuntu --release noble --name ubuntu-dev --docker --brew

# Fedora testing environment
./bin/vm-create --distro fedora --release 42 --name fedora-test --brew

# Arch Linux minimal development setup
./bin/vm-create --distro arch --name arch-dev --disk-size 60G --brew

# Debian stable server
./bin/vm-create --distro debian --release bookworm --name debian-server --docker
```
