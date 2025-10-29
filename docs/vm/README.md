# vm-create - Advanced VM Creation Utility

The `vm-create` script provides more advanced VM creation options with additional software installation capabilities. This is a more feature-rich alternative to `vme-create`.

## Usage

```bash
vm-create --distro DISTRO [OPTIONS]
```

## Required Options

- `--distro DISTRO` - Distribution to install (ubuntu|fedora|arch|debian|alpine|tumbleweed)

## Important Options

### Basic Configuration
- `--name NAME` - VM name (default: distribution name)
- `--memory MB` - RAM in MB (default: 8192)
- `--vcpus NUM` - Number of vCPUs (default: 4)
- `--disk-size SIZE` - Disk size (default: 40G)
- `--username USER` - VM username (default: distribution-specific)
- `--password PASS` - Set password for VM user (default: same as username)

### Network Configuration
- `--bridge BRIDGE` - Network bridge (default: virbr0)
- `--ssh-key PATH` - SSH public key path (default: auto-detect)

### Software Installation Options
- `--docker` - Install Docker in the VM with proper user permissions
- `--brew` - Install Homebrew and essential development tools
- `--nix` - Install Nix package manager using Determinate Systems installer
- `--dotfiles OPTIONS...` - Install dotfiles with specified options (must be last argument)

## Supported Distributions

| Distribution        | Default Release  | Default VM Name | Default Username |
| ------------------- | ---------------- | --------------- | ---------------- |
| Ubuntu              | questing (25.10) | ubuntu          | ubuntu           |
| Fedora              | 42               | fedora          | fedora           |
| Arch Linux          | latest           | arch            | arch             |
| Debian              | trixie (13)      | debian          | debian           |
| Alpine              | 3.22             | alpine          | alpine           |
| openSUSE Tumbleweed | latest           | tw              | opensuse         |

## Software Installation Details

### Docker Installation
When `--docker` is used:
- Docker Engine is installed using the official installation method
- User is added to the docker group for non-root usage
- Docker Compose is included where available
- Service is enabled and started automatically

### Homebrew Installation
When `--brew` is used:
- Homebrew is installed non-interactively
- Essential development tools are pre-installed:
  - stow (for dotfiles management)
  - starship (prompt)
  - fzf (fuzzy finder)
  - ripgrep (search tool)
  - eza (ls replacement)
  - zoxide (cd replacement)
  - fd (find replacement)
  - bat (cat replacement)
- Shell environment is configured in .bashrc and .profile

### Nix Installation
When `--nix` is used:
- Nix is installed using the Determinate Systems installer
- Nix daemon is enabled and started
- Shell environment is configured for all users
- Single-user and multi-user configurations are set up

### Dotfiles Installation
When `--dotfiles` is used:
- Must be the last option as it consumes all remaining arguments
- Installs the ILM dotfiles framework
- Common options include:
  - `shell-slim` - Minimal shell configuration
  - `docker` - Docker configuration files
  - `code-server` - Remote development setup
  - `python` - Python development environment
- Creates ~/.ilm directory with configuration management

## Examples

```bash
# Basic Ubuntu VM
vm-create --distro ubuntu

# Custom VM with specific resources
vm-create --distro fedora --name dev-vm --memory 16384 --vcpus 8 --disk-size 100G

# Ubuntu VM with Docker pre-installed
vm-create --distro ubuntu --name docker-dev --docker

# Development environment with all tools
vm-create --distro arch --name arch-dev --docker --brew --nix

# Full development setup with dotfiles
vm-create --distro ubuntu --name ubuntu-dev --docker --brew --dotfiles shell-slim docker code-server

# Alpine Linux for container testing
vm-create --distro alpine --name alpine-test --vcpus 2 --memory 2048 --disk-size 20G
```

## Differences from vme-create

| Feature               | vme-create | vm-create                       |
| --------------------- | ---------- | ------------------------------- |
| Interactive mode      | Yes        | No                              |
| Software installation | No         | Docker, Brew, Nix, Dotfiles     |
| Default disk size     | 30G        | 40G                             |
| Default memory        | 8192MB     | 8192MB                          |
| Supported distros     | 5          | 6 (includes Alpine)             |
| Cloud-init packages   | Minimal    | Comprehensive development tools |

## VM Management with `vm` Command

The `vm` script (located at `bin/vt/vm`) provides a comprehensive interface for managing VMs created with `vm-create`. It offers lifecycle management, monitoring, and advanced device handling capabilities.

### Basic VM Management Workflow

```bash
# 1. Install virtualization tools (first-time setup)
vm install

# 2. Create a new VM
vm create --distro ubuntu --name dev-vm --memory 8192 --vcpus 4 --docker

# 3. List all VMs
vm list

# 4. Start the VM
vm start dev-vm

# 5. Check VM status and get IP address
vm status dev-vm
vm ip dev-vm

# 6. Connect to the VM via SSH
vm ssh dev-vm

# 7. When finished, stop the VM
vm stop dev-vm
```

### Advanced Usage Examples

#### USB Device Management
```bash
# List available USB devices on host
vm usb-list

# Attach USB device to VM (using vendor:product ID)
vm usb-attach dev-vm 1234:5678

# Attach USB device to VM (using bus.device format)
vm usb-attach dev-vm 001.002

# List USB devices attached to VM
vm usb-attached dev-vm

# Detach USB device from VM
vm usb-detach dev-vm 1234:5678
```

#### Disk Device Management
```bash
# List available block devices on host
vm disk-list

# Attach raw disk device to VM
vm disk-attach dev-vm /dev/sdb

# List disk devices attached to VM
vm disk-attached dev-vm

# Detach disk device from VM
vm disk-detach dev-vm /dev/sdb
```

#### VM Cloning and Cleanup
```bash
# Clone an existing VM
vm clone dev-vm dev-vm-copy

# Clean up stopped VMs and orphaned files
vm cleanup

# Delete a VM completely
vm delete old-vm
```

### Troubleshooting Tips

#### VM Creation Issues
- **Problem**: `vm-create` command not found
  - **Solution**: Run `vm install` to install virtualization tools
  - **Alternative**: Ensure `bin/vt` is in your PATH

- **Problem**: VM creation fails with permission errors
  - **Solution**: Add your user to the libvirt group: `sudo usermod -aG libvirt $USER`
  - **Solution**: Log out and back in, or run `newgrp libvirt`

#### VM Startup Issues
- **Problem**: VM fails to start
  - **Solution**: Check VM status with `vm status <vm-name>`
  - **Solution**: View VM logs with `vm logs <vm-name>`
  - **Solution**: Check cloud-init logs with `vm cloud-init-logs <vm-name>`

- **Problem**: VM starts but no network connectivity
  - **Solution**: Verify bridge configuration: `virsh net-list --all`
  - **Solution**: Check if VM got IP address: `vm ip <vm-name>`
  - **Solution**: Restart libvirt network: `sudo virsh net-start default`

#### SSH Connection Issues
- **Problem**: Cannot SSH into VM
  - **Solution**: Ensure VM is running: `vm status <vm-name>`
  - **Solution**: Check if VM has IP address: `vm ip <vm-name>`
  - **Solution**: Try connecting with explicit username: `vm ssh <vm-name> ubuntu`
  - **Solution**: Check if SSH key was properly injected during creation

#### USB Device Issues
- **Problem**: USB device not found
  - **Solution**: List available devices: `vm usb-list`
  - **Solution**: Check device permissions: `ls -l /dev/bus/usb/*/*`
  - **Solution**: Ensure user has access to USB devices

- **Problem**: USB device attachment fails
  - **Solution**: Ensure VM is running: `vm status <vm-name>`
  - **Solution**: Check if device is already attached: `vm usb-attached <vm-name>`
  - **Solution**: Try detaching and re-attaching the device

#### Disk Device Issues
- **Problem**: Cannot attach disk device
  - **Solution**: Ensure disk is not mounted: `lsblk -f /dev/sdX`
  - **Solution**: Unmount disk if necessary: `sudo umount /dev/sdX*`
  - **Solution**: Check disk permissions: `ls -l /dev/sdX`

- **Problem**: Disk attachment fails with "device in use" error
  - **Solution**: Check for processes using the disk: `sudo lsof /dev/sdX`
  - **Solution**: Ensure no partitions are mounted: `mount | grep /dev/sdX`
  - **Solution**: Try detaching and re-attaching the device

#### Performance Issues
- **Problem**: VM runs slowly
  - **Solution**: Check available host resources: `free -h` and `df -h`
  - **Solution**: Adjust VM resources: `vm destroy <vm-name>` then recreate with more memory/CPU
  - **Solution**: Enable KVM acceleration: check `/dev/kvm` exists and is accessible

#### General Troubleshooting Commands
```bash
# Check VM status and configuration
vm status <vm-name>
virsh dominfo <vm-name>

# View VM logs
vm logs <vm-name>
sudo tail -f /var/log/libvirt/qemu/<vm-name>.log

# Check network configuration
virsh net-list --all
virsh net-info default

# Check libvirt service status
sudo systemctl status libvirtd
sudo systemctl status virtlogd

# Reset libvirt services if needed
sudo systemctl restart libvirtd
sudo systemctl restart virtlogd
```

## Batch VM Management with `vm-all`

The `vm-all` script (located at `bin/vt/vm-all`) provides batch operations for managing multiple VMs simultaneously. It's designed to work with a predefined set of distributions (Ubuntu, Fedora, Debian, Arch, Alpine).

### Basic Usage

```bash
# Create all VMs (ubuntu-vm, fedora-vm, debian-vm, arch-vm, alpine-vm)
vm-all create

# Start all VMs
vm-all start

# Stop all VMs
vm-all stop

# Restart all VMs
vm-all restart

# Delete all VMs
vm-all delete
```

### Advanced Workflow Example

```bash
# 1. Create all VMs with default configurations
vm-all create

# 2. Start all VMs
vm-all start

# 3. Check status of all VMs
for vm in ubuntu-vm fedora-vm debian-vm arch-vm alpine-vm; do
    echo "=== $vm Status ==="
    vm status "$vm"
    echo
done

# 4. When finished, stop all VMs
vm-all stop

# 5. Clean up by deleting all VMs
vm-all delete
```

### Troubleshooting `vm-all`

- **Problem**: Some VMs fail to create
  - **Solution**: Check available disk space: `df -h /var/lib/libvirt/images/`
  - **Solution**: Check available memory: `free -h`
  - **Solution**: Create VMs individually to identify specific issues

- **Problem**: VMs already exist
  - **Solution**: The script automatically skips existing VMs
  - **Solution**: To recreate, delete first: `vm-all delete` then `vm-all create`

## Tmux-based VM Management with `vm-tmux`

The `vm-tmux` script (located at `bin/vt/vm-tmux`) provides a convenient way to manage SSH connections to multiple VMs within a single tmux session. This is ideal for managing multiple VMs simultaneously without opening multiple terminal windows.

### Basic Usage

```bash
# Create a new tmux session with SSH connections to all VMs (or attach if exists)
vm-tmux

# Explicitly create a new session
vm-tmux create

# Attach to an existing session
vm-tmux attach

# Detach from the current session (press Ctrl+B then D inside tmux)
vm-tmux detach

# Kill the tmux session completely
vm-tmux destroy
```

### Workflow Example

```bash
# 1. Ensure VMs are created and running
vm-all create
vm-all start

# 2. Create tmux session with SSH connections to all VMs
vm-tmux create

# 3. Inside tmux:
#    - Navigate between panes: Ctrl+B then Arrow keys
#    - Switch between windows: Ctrl+B then 0-4
#    - Detach from session: Ctrl+B then D
#    - Reattach later: vm-tmux attach

# 4. When finished, clean up
vm-tmux destroy
vm-all stop
```

### Tmux Session Layout

The `vm-tmux` script creates a grid layout with SSH connections to:
- Window 0: Ubuntu VM
- Window 1: Fedora VM
- Window 2: Arch VM
- Window 3: Debian VM
- Window 4: Alpine VM

### Troubleshooting `vm-tmux`

- **Problem**: Cannot create tmux session
  - **Solution**: Ensure tmux is installed: `which tmux`
  - **Solution**: Install tmux if missing: `sudo apt install tmux` (Ubuntu/Debian) or `sudo dnf install tmux` (Fedora)

- **Problem**: SSH connections fail
  - **Solution**: Ensure VMs are running: `vm-all status` or check individual VMs
  - **Solution**: Check if VMs have IP addresses: `for vm in ubuntu-vm fedora-vm debian-vm arch-vm alpine-vm; do echo "$vm: $(vm ip "$vm" 2>/dev/null || echo "No IP")"; done`
  - **Solution**: Check SSH key authentication: try connecting manually: `vm ssh ubuntu-vm`

- **Problem**: Session already exists
  - **Solution**: Attach to existing session: `vm-tmux attach`
  - **Solution**: Destroy and recreate: `vm-tmux destroy && vm-tmux create`

- **Problem**: Cannot detach from session
  - **Solution**: Use tmux detach command: Press Ctrl+B then D
  - **Solution**: Or use external command: `vm-tmux detach`

### Combining Tools for Efficient Workflow

```bash
# Complete workflow for testing across multiple distributions
vm-all create          # Create all VMs
vm-all start          # Start all VMs
sleep 60              # Wait for VMs to fully boot
vm-tmux create        # Create tmux session with SSH connections

# Work with all VMs simultaneously in tmux
# When done:
vm-tmux destroy       # Close tmux session
vm-all stop          # Stop all VMs
```
