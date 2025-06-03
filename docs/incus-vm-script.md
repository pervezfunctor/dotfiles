# incus-vm - Incus Virtual Machine Management Script

The `incus-vm` script provides a unified interface for managing Incus virtual machines, similar to how the `vm` script manages libvirt VMs and the `dt` script manages distrobox containers. It offers a consistent command-line experience for creating, managing, and interacting with Incus VMs.

## Features

- **VM Lifecycle Management**: Create, start, stop, restart, and delete VMs
- **Interactive Operations**: Console access, command execution, status monitoring
- **Incus-Specific Features**: Snapshots, VM copying, detailed configuration management
- **Cleanup Operations**: Remove stopped VMs and manage resources
- **Integration**: Works with existing Incus VM creation functions from `share/fns`

## Commands

### Installation
- `incus-vm install` - Install Incus using ilm-installer

### Basic Operations
- `incus-vm list` - List all Incus VMs
- `incus-vm status <name>` - Show VM status and basic info
- `incus-vm create <distro> [name]` - Create a new Incus VM
- `incus-vm start <name>` - Start a VM
- `incus-vm stop <name>` - Stop a VM
- `incus-vm restart <name>` - Restart a VM
- `incus-vm delete <name>` - Delete a VM completely (with confirmation)

### Interactive Operations
- `incus-vm console <name>` - Connect to VM console
- `incus-vm exec <name> <command>` - Execute command in VM

### Network Operations
- `incus-vm ip <name>` - Get VM IP address
- `incus-vm ssh <name> [username]` - Connect to VM via SSH

### Information and Configuration
- `incus-vm info <name>` - Show detailed VM information
- `incus-vm config <name>` - Show VM configuration

### Snapshot Management
- `incus-vm snapshot <name> [snapshot-name]` - Create VM snapshot
- `incus-vm restore <name> <snapshot-name>` - Restore VM from snapshot

### Advanced Operations
- `incus-vm copy <source> <destination>` - Copy VM
- `incus-vm cleanup` - Remove stopped VMs

## Supported Distributions

The script supports creating VMs for the following distributions:
- ubuntu, fedora, arch, tumbleweed, debian, centos, alpine

## Examples

```bash
# Install Incus
incus-vm install

# List all VMs
incus-vm list

# Create an Ubuntu VM with default name
incus-vm create ubuntu

# Create a Fedora VM with custom name
incus-vm create fedora my-fedora-vm

# Start a VM
incus-vm start ubuntu-vm

# Connect to VM console
incus-vm console ubuntu-vm

# Execute a command in VM
incus-vm exec ubuntu-vm "apt update && apt install -y vim"

# Get VM IP address
incus-vm ip ubuntu-vm

# SSH to VM (auto-detect username)
incus-vm ssh ubuntu-vm

# SSH to VM with specific username
incus-vm ssh ubuntu-vm ubuntu

# Show detailed VM information
incus-vm info ubuntu-vm

# Create a snapshot
incus-vm snapshot ubuntu-vm before-update

# Restore from snapshot
incus-vm restore ubuntu-vm before-update

# Copy a VM
incus-vm copy ubuntu-vm ubuntu-vm-backup

# Show VM configuration
incus-vm config ubuntu-vm

# Clean up stopped VMs
incus-vm cleanup

# Delete a VM (with confirmation)
incus-vm delete old-vm
```

## Integration with Existing Functions

The script automatically sources and uses existing Incus VM creation functions from `share/fns` when available, including:
- `incus-ubuntu-vm`, `incus-fedora-vm`, `incus-arch-vm`, etc.

If these functions aren't available, it falls back to direct `incus launch` commands with appropriate image names.

## Key Features

### Snapshot Management
Unlike traditional VMs, Incus provides excellent snapshot capabilities:
- Automatic snapshot naming with timestamps
- Easy restore with confirmation prompts
- Snapshot-based VM copying

### Console Access
Direct console access without SSH setup:
- `incus-vm console <name>` connects directly to VM console
- No network configuration required
- Works immediately after VM creation

### Command Execution
Execute commands directly in VMs:
- `incus-vm exec <name> <command>` runs commands without SSH
- Useful for automation and quick tasks
- No authentication setup required

### Network Access
IP discovery and SSH connectivity:
- `incus-vm ip <name>` gets VM IP address using multiple detection methods
- `incus-vm ssh <name>` connects via SSH with automatic username detection
- Supports distro-specific users (ubuntu, fedora, etc.)
- Fallback to ubuntu for unknown VM patterns

## Error Handling

The script includes comprehensive error handling:
- Validates Incus installation before operations
- Checks VM existence before operations
- Provides clear error messages and usage information
- Confirms destructive operations (delete, restore)
- Handles missing dependencies gracefully

## Comparison with Other VM Scripts

| Feature         | `vm` (libvirt)                | `incus-vm` (Incus)           | `dt` (Distrobox)      |
| --------------- | ----------------------------- | ---------------------------- | --------------------- |
| List            | `vm list`                     | `incus-vm list`              | `dt list`             |
| Status          | `vm status <name>`            | `incus-vm status <name>`     | `dt status <name>`    |
| Create          | `vm create --distro <distro>` | `incus-vm create <distro>`   | `dt create <distro>`  |
| Start           | `vm start <name>`             | `incus-vm start <name>`      | `dt start <name>`     |
| Stop            | `vm stop <name>`              | `incus-vm stop <name>`       | `dt stop <name>`      |
| Connect         | `vm ssh <name>`               | `incus-vm console <name>`    | `dt enter <name>`     |
| Execute         | `vm ssh <name> "cmd"`         | `incus-vm exec <name> "cmd"` | `dt run <name> "cmd"` |
| IP Address      | `vm ip <name>`                | `incus-vm ip <name>`         | N/A                   |
| SSH Access      | `vm ssh <name>`               | `incus-vm ssh <name>`        | N/A                   |
| Delete          | `vm delete <name>`            | `incus-vm delete <name>`     | `dt delete <name>`    |
| Unique Features | Advanced SSH features         | Snapshots, Copy, Config      | App export/import     |

## Installation

The script includes a built-in installation command that uses `ilm-installer` to install and configure Incus:

```bash
# Install Incus automatically
incus-vm install
```

This command will:
- Install Incus package for your distribution
- Add your user to `incus` and `incus-admin` groups
- Enable and start Incus services
- Configure firewall rules (if needed)
- Initialize Incus with minimal configuration

After installation, you may need to log out and back in, or run `newgrp incus` for group changes to take effect.

## Prerequisites

- Incus installed and configured (use `incus-vm install` if not installed)
- User added to `incus` and `incus-admin` groups
- Incus daemon running

## Installation Notes

The script integrates with the existing Incus installation functions in `share/installers/` which handle:
- Package installation
- User group configuration
- Service enablement
- Firewall configuration (if needed)
- Initial Incus setup

This provides a consistent interface across different virtualization technologies while leveraging Incus's unique capabilities like snapshots, instant console access, and efficient VM copying.
