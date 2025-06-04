# vm - Virtual Machine Management Script

The `vm` script provides a unified interface for managing virtual machines created with libvirt/KVM, similar to how other management scripts work in the ecosystem. It offers a consistent command-line experience for creating, managing, and interacting with VMs.

## Features

- **VM Lifecycle Management**: List, start, stop, restart, and delete VMs
- **Interactive Operations**: Console access, SSH connections, status monitoring
- **VM Creation**: Integration with vm-create script for new VM creation
- **Cleanup Operations**: Remove stopped VMs and orphaned files
- **Installation**: Built-in installation of virtualization tools

## Commands

### Installation
- `vm install` - Install virtualization tools (libvirt, QEMU, virt-install) using ilmi

### Basic Operations
- `vm list` - List all VMs
- `vm status <name>` - Show VM status and detailed info
- `vm create ARGS` - Create a new VM (same args as vm-create)
- `vm start <name>` - Start a VM
- `vm stop <name>` - Gracefully stop a VM
- `vm restart <name>` - Restart a VM
- `vm destroy <name>` - Force stop a VM
- `vm delete <name>` - Delete a VM completely

### Interactive Operations
- `vm console <name>` - Connect to VM console
- `vm ssh <name> [user]` - Connect to VM via SSH (auto-detects username)

### Information and Management
- `vm ip <name>` - Get VM IP address
- `vm logs <name>` - Show VM logs
- `vm autostart <name>` - Set VM to start on boot
- `vm cleanup` - Remove stopped VMs and orphaned files

## Examples

```bash
# Install virtualization tools
vm install

# List all VMs
vm list

# Create a new Ubuntu VM
vm create --distro ubuntu

# Start a VM
vm start ubuntu

# Connect to VM console
vm console ubuntu

# SSH to VM (auto-detects username)
vm ssh ubuntu

# SSH to VM with specific username
vm ssh fedora fedora

# Get VM IP address
vm ip ubuntu

# Stop VM gracefully
vm stop ubuntu

# Delete VM completely
vm delete old-vm

# Clean up stopped VMs
vm cleanup
```

## Installation

The script includes a built-in installation command that uses `ilmi` to install virtualization tools:

```bash
# Install virtualization tools automatically
vm install
```

This command will:
- Install libvirt package for your distribution
- Install QEMU/KVM virtualization platform
- Install virt-install for VM creation
- Install bridge utilities for networking
- Add your user to libvirt group
- Enable and start libvirt services
- Configure firewall rules (if needed)

The installation includes:
- **libvirt** - Virtualization management library
- **QEMU/KVM** - Hardware virtualization platform
- **virt-install** - Command-line VM installation tool
- **bridge-utils** - Network bridge utilities
- **vm-create scripts** - Enhanced VM creation tools

After installation, you may need to log out and back in, or run `newgrp libvirt` for group changes to take effect.

## SSH Access

The `vm ssh` command provides intelligent SSH access with automatic username detection:

### Username Auto-Detection
- **CoreOS VMs**: Uses `coreos` user (previously `core`)
- **Fedora VMs**: Uses `fedora` user
- **Debian VMs**: Uses `debian` user
- **Arch VMs**: Uses `arch` user
- **Other VMs**: Defaults to `ubuntu` user

### SSH Examples
```bash
# Auto-detect username based on VM name
vm ssh ubuntu          # Uses 'ubuntu' user
vm ssh fedora          # Uses 'fedora' user
vm ssh coreos          # Uses 'coreos' user

# Override username
vm ssh myvm custom_user
```

## Integration with VM Creation

The `vm` script integrates seamlessly with the `vm-create` script:

```bash
# Create VM using vm script (passes args to vm-create)
vm create --distro ubuntu --name myvm --memory 8192

# Equivalent direct call
vm-create --distro ubuntu --name myvm --memory 8192

# Manage the created VM
vm start myvm
vm ssh myvm
vm stop myvm
```

## Prerequisites

- Virtualization tools installed (use `vm install` if not installed)
- User added to `libvirt` group
- libvirt daemon running
- Hardware virtualization support (Intel VT-x or AMD-V)

## Troubleshooting

### Installation Issues
- Ensure hardware virtualization is enabled in BIOS
- Check if virtualization is supported: `egrep -c '(vmx|svm)' /proc/cpuinfo`
- Verify libvirt service: `systemctl status libvirtd`

### Permission Issues
- Check user groups: `groups $USER` (should include libvirt)
- Add user to group: `sudo usermod -a -G libvirt $USER`
- Log out and back in for group changes

### VM Access Issues
- Check VM status: `vm status VM_NAME`
- Verify VM IP: `vm ip VM_NAME`
- Check SSH service in VM: `vm console VM_NAME`

## Comparison with Other Management Scripts

| Feature         | `vm` (libvirt)                   | `ivm` (Incus)           | `dt` (Distrobox)      | `ict` (Incus LXC)          |
| --------------- | -------------------------------- | ----------------------- | --------------------- | -------------------------- |
| Install         | `vm install`                     | `ivm install`           | `dt install`          | `ict install`              |
| List            | `vm list`                        | `ivm list`              | `dt list`             | `ict list`                 |
| Create          | `vm create --distro <distro>`    | `ivm create <distro>`   | `dt create <distro>`  | `ict create <distro>`      |
| Start           | `vm start <name>`                | `ivm start <name>`      | `dt start <name>`     | `ict start <name>`         |
| Connect         | `vm ssh <name>`                  | `ivm console <name>`    | `dt enter <name>`     | `ict shell <name>`         |
| Execute         | `vm ssh <name> "cmd"`            | `ivm exec <name> "cmd"` | `dt run <name> "cmd"` | `ict exec <name> "cmd"`    |
| Unique Features | SSH auto-detection, IP detection | Snapshots, Copy         | App export/import     | Snapshots, Privileged mode |

## Performance and Use Cases

### Traditional VMs (vm script)
**Advantages:**
- Complete hardware isolation
- Different kernels and OS versions
- Full virtualization capabilities
- Mature ecosystem and tooling

**Use Cases:**
- Production-like environments
- Security testing and isolation
- Different OS versions
- Legacy application testing
- Network service development

### Resource Requirements
- **CPU**: Requires hardware virtualization support
- **Memory**: Higher overhead (512MB+ per VM)
- **Disk**: Full OS installation (several GB per VM)
- **Network**: Bridge networking with full IP stack

This script provides a comprehensive interface for traditional virtualization needs while maintaining consistency with the other management tools in the ecosystem.
