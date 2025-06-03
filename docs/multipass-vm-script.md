# multipass-vm - Multipass Virtual Machine Management Script

The `multipass-vm` script provides a unified interface for managing Multipass virtual machines, similar to how the `vm` script manages libvirt VMs and the `incus-vm` script manages Incus VMs. It offers a consistent command-line experience for creating, managing, and interacting with Multipass VMs with SSH support.

## Features

- **VM Lifecycle Management**: Create, start, stop, restart, and delete VMs
- **Interactive Operations**: Shell access, command execution, status monitoring
- **SSH Support**: Automatic SSH setup with cloud-init and username detection
- **Directory Mounting**: Mount host directories in VMs for easy file sharing
- **Multi-Distribution Support**: Ubuntu, Fedora with version-specific options
- **Integration**: Works with existing ilm-installer for Multipass installation

## Commands

### Installation
- `multipass-vm install` - Install Multipass using ilm-installer

### Basic Operations
- `multipass-vm list` - List all Multipass VMs
- `multipass-vm status <name>` - Show VM status and basic info
- `multipass-vm create <distro> [name]` - Create a new Multipass VM
- `multipass-vm start <name>` - Start a VM
- `multipass-vm stop <name>` - Stop a VM
- `multipass-vm restart <name>` - Restart a VM
- `multipass-vm delete <name>` - Delete a VM completely (with confirmation)

### Interactive Operations
- `multipass-vm shell <name>` - Connect to VM shell (multipass shell)
- `multipass-vm exec <name> <command>` - Execute command in VM

### Network Operations
- `multipass-vm ip <name>` - Get VM IP address
- `multipass-vm ssh <name> [username]` - Connect to VM via SSH

### Information
- `multipass-vm info <name>` - Show detailed VM information

### File System Operations
- `multipass-vm mount <name> <src> <dst>` - Mount host directory in VM
- `multipass-vm umount <name> <path>` - Unmount directory from VM

## Supported Distributions

Multipass supports Ubuntu distributions using their codenames and aliases:

- **ubuntu** - Ubuntu (latest)
- **lts** - Ubuntu (latest LTS alias)
- **jammy** - Ubuntu 22.04 LTS
- **noble** - Ubuntu 24.04 LTS
- **oracular** - Ubuntu 24.10
- **plucky** - Ubuntu 25.04

Note: The script uses Multipass image names directly (codenames and aliases) for simplicity. While Multipass can technically support other distributions through custom cloud images, this script focuses on the officially supported Ubuntu variants.

## Usage Examples

```bash
# Install Multipass
multipass-vm install

# List all VMs
multipass-vm list

# Create an Ubuntu VM with default name
multipass-vm create ubuntu

# Create an Ubuntu 24.10 VM with custom name
multipass-vm create oracular my-ubuntu-vm

# Create an Ubuntu 22.04 LTS VM
multipass-vm create jammy

# Create latest LTS VM
multipass-vm create lts

# Start a VM
multipass-vm start ubuntu-vm

# Connect to VM shell
multipass-vm shell ubuntu-vm

# Execute a command in VM
multipass-vm exec ubuntu-vm "apt update && apt install -y vim"

# Get VM IP address
multipass-vm ip ubuntu-vm

# SSH to VM (auto-detect username)
multipass-vm ssh ubuntu-vm

# SSH to VM with specific username
multipass-vm ssh ubuntu-vm ubuntu

# Mount host directory in VM
multipass-vm mount ubuntu-vm ~/code /home/ubuntu/code

# Show detailed VM information
multipass-vm info ubuntu-vm

# Unmount directory from VM
multipass-vm umount ubuntu-vm /home/ubuntu/code

# Stop a VM
multipass-vm stop ubuntu-vm

# Delete a VM (with confirmation)
multipass-vm delete old-vm
```

## SSH Access

The script automatically configures SSH access during VM creation:

### Automatic SSH Setup
- Generates SSH key pair if not present (`~/.ssh/id_rsa`)
- Configures cloud-init to add public key to VM
- Enables SSH service in the VM
- Configures firewall to allow SSH connections

### Username Detection
Since Multipass primarily supports Ubuntu, the script uses the `ubuntu` user for all VMs:
- All Multipass VMs → `ubuntu` user (default and primary)
- This provides consistency across all Ubuntu variants supported by Multipass

### SSH Connection Methods
```bash
# Direct SSH with auto-detected username
multipass-vm ssh vm-name

# SSH with specific username (though ubuntu is standard)
multipass-vm ssh vm-name ubuntu

# Get IP for manual SSH
IP=$(multipass-vm ip vm-name)
ssh ubuntu@$IP
```

## Directory Mounting

Multipass provides seamless directory mounting between host and VM:

```bash
# Mount host directory to VM
multipass-vm mount ubuntu-vm ~/projects /home/ubuntu/projects

# Access files in VM
multipass-vm shell ubuntu-vm
cd /home/ubuntu/projects
ls -la

# Unmount when done
multipass-vm umount ubuntu-vm /home/ubuntu/projects
```

## VM Creation Process

When creating a VM, the script:

1. **Validates** distribution support and VM name availability
2. **Generates** SSH key pair if missing
3. **Creates** cloud-init configuration with:
   - User account setup with sudo privileges
   - SSH key authorization
   - SSH service enablement
   - Firewall configuration
4. **Launches** VM with specified resources (2 CPUs, 4GB RAM, 20GB disk)
5. **Waits** for VM to be ready
6. **Displays** connection information

## Error Handling

The script provides comprehensive error handling:
- **VM existence checks** before operations
- **State validation** (running/stopped) for appropriate commands
- **Network connectivity** verification for SSH operations
- **Resource availability** checks for mounting operations
- **User confirmation** for destructive operations (delete)

## Integration with Other Scripts

### Comparison with Other VM Management Scripts

| Feature         | `vm` (libvirt)         | `multipass-vm`                   | `incus-vm`                   |
| --------------- | ---------------------- | -------------------------------- | ---------------------------- |
| Installation    | `vm install`           | `multipass-vm install`           | `incus-vm install`           |
| List VMs        | `vm list`              | `multipass-vm list`              | `incus-vm list`              |
| Create VM       | `vm create <distro>`   | `multipass-vm create <distro>`   | `incus-vm create <distro>`   |
| Start/Stop      | `vm start/stop <name>` | `multipass-vm start/stop <name>` | `incus-vm start/stop <name>` |
| Connect         | `vm ssh <name>`        | `multipass-vm shell <name>`      | `incus-vm console <name>`    |
| Execute         | `vm ssh <name> "cmd"`  | `multipass-vm exec <name> "cmd"` | `incus-vm exec <name> "cmd"` |
| IP Address      | `vm ip <name>`         | `multipass-vm ip <name>`         | `incus-vm ip <name>`         |
| SSH Access      | `vm ssh <name>`        | `multipass-vm ssh <name>`        | `incus-vm ssh <name>`        |
| Delete          | `vm delete <name>`     | `multipass-vm delete <name>`     | `incus-vm delete <name>`     |
| Unique Features | Advanced networking    | Directory mounting               | Snapshots, Copy, Config      |

## Installation

The script can install Multipass automatically:

```bash
# Install Multipass using ilm-installer
multipass-vm install
```

This will:
- Download and install Multipass using the ilm-installer
- Set up the Multipass daemon
- Verify installation success
- Provide usage examples

## Prerequisites

- Linux, macOS, or Windows with WSL2
- Internet connection for downloading VM images
- Sufficient disk space for VM storage (20GB+ per VM)
- SSH client for SSH connections

## Troubleshooting

### Common Issues

1. **Multipass not found**: Run `multipass-vm install` to install
2. **VM creation fails**: Check internet connection and disk space
3. **SSH connection fails**: Ensure VM is running and SSH is configured
4. **Mount fails**: Verify source directory exists and VM is running

### Debug Information

```bash
# Check VM status
multipass-vm status vm-name

# Get detailed VM information
multipass-vm info vm-name

# Check VM IP address
multipass-vm ip vm-name

# Test direct shell access
multipass-vm shell vm-name
```

## Completion Support

The script includes bash and zsh completion support:
- **Bash**: `share/completions/multipass-vm.bash`
- **Zsh**: `share/completions/_multipass-vm`

Completions provide:
- Command completion
- VM name completion
- Distribution completion
- Username completion for SSH
- Directory completion for mounting
