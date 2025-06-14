# mvm - Multipass Virtual Machine Management Script

The `mvm` script provides a unified interface for managing Multipass virtual machines, similar to how the `vm` script manages libvirt VMs and the `ivm` script manages Incus VMs. It offers a consistent command-line experience for creating, managing, and interacting with Multipass VMs with SSH support.

## Features

- **VM Lifecycle Management**: Create, start, stop, restart, and delete VMs
- **Interactive Operations**: Shell access, command execution, status monitoring
- **SSH Support**: Automatic SSH setup with cloud-init and username detection
- **Directory Mounting**: Mount host directories in VMs for easy file sharing
- **Multi-Distribution Support**: Ubuntu, Fedora with version-specific options
- **Integration**: Works with existing ilmi for Multipass installation

## Commands

### Installation
- `mvm install` - Install Multipass using ilmi

### Basic Operations
- `mvm list` - List all Multipass VMs
- `mvm status <name>` - Show VM status and basic info
- `mvm create <distro> [name]` - Create a new Multipass VM
- `mvm start <name>` - Start a VM
- `mvm stop <name>` - Stop a VM
- `mvm restart <name>` - Restart a VM
- `mvm delete <name>` - Delete a VM completely (with confirmation)

### Interactive Operations
- `mvm shell <name>` - Connect to VM shell (multipass shell)
- `mvm exec <name> <command>` - Execute command in VM

### Network Operations
- `mvm ip <name>` - Get VM IP address
- `mvm ssh <name> [username]` - Connect to VM via SSH

### Information
- `mvm info <name>` - Show detailed VM information

### File System Operations
- `mvm mount <name> <src> <dst>` - Mount host directory in VM
- `mvm umount <name> <path>` - Unmount directory from VM

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
mvm install

# List all VMs
mvm list

# Create an Ubuntu VM with default name
mvm create ubuntu

# Create an Ubuntu 24.10 VM with custom name
mvm create oracular my-ubuntu-vm

# Create an Ubuntu 22.04 LTS VM
mvm create jammy

# Create latest LTS VM
mvm create lts

# Start a VM
mvm start ubuntu-vm

# Connect to VM shell
mvm shell ubuntu-vm

# Execute a command in VM
mvm exec ubuntu-vm "apt update && apt install -y vim"

# Get VM IP address
mvm ip ubuntu-vm

# SSH to VM (auto-detect username)
mvm ssh ubuntu-vm

# SSH to VM with specific username
mvm ssh ubuntu-vm ubuntu

# Mount host directory in VM
mvm mount ubuntu-vm ~/code /home/ubuntu/code

# Show detailed VM information
mvm info ubuntu-vm

# Unmount directory from VM
mvm umount ubuntu-vm /home/ubuntu/code

# Stop a VM
mvm stop ubuntu-vm

# Delete a VM (with confirmation)
mvm delete old-vm
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
mvm ssh vm-name

# SSH with specific username (though ubuntu is standard)
mvm ssh vm-name ubuntu

# Get IP for manual SSH
IP=$(mvm ip vm-name)
ssh ubuntu@$IP
```

## Directory Mounting

Multipass provides seamless directory mounting between host and VM:

```bash
# Mount host directory to VM
mvm mount ubuntu-vm ~/projects /home/ubuntu/projects

# Access files in VM
mvm shell ubuntu-vm
cd /home/ubuntu/projects
ls -la

# Unmount when done
mvm umount ubuntu-vm /home/ubuntu/projects
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

| Feature         | `vm` (libvirt)         | `mvm`                   | `ivm`                   |
| --------------- | ---------------------- | ----------------------- | ----------------------- |
| Installation    | `vm install`           | `mvm install`           | `ivm install`           |
| List VMs        | `vm list`              | `mvm list`              | `ivm list`              |
| Create VM       | `vm create <distro>`   | `mvm create <distro>`   | `ivm create <distro>`   |
| Start/Stop      | `vm start/stop <name>` | `mvm start/stop <name>` | `ivm start/stop <name>` |
| Connect         | `vm ssh <name>`        | `mvm shell <name>`      | `ivm console <name>`    |
| Execute         | `vm ssh <name> "cmd"`  | `mvm exec <name> "cmd"` | `ivm exec <name> "cmd"` |
| IP Address      | `vm ip <name>`         | `mvm ip <name>`         | `ivm ip <name>`         |
| SSH Access      | `vm ssh <name>`        | `mvm ssh <name>`        | `ivm ssh <name>`        |
| Delete          | `vm delete <name>`     | `mvm delete <name>`     | `ivm delete <name>`     |
| Unique Features | Advanced networking    | Directory mounting      | Snapshots, Copy, Config |

## Installation

The script can install Multipass automatically:

```bash
# Install Multipass using ilmi
mvm install
```

This will:
- Download and install Multipass using the ilmi
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

1. **Multipass not found**: Run `mvm install` to install
2. **VM creation fails**: Check internet connection and disk space
3. **SSH connection fails**: Ensure VM is running and SSH is configured
4. **Mount fails**: Verify source directory exists and VM is running

### Debug Information

```bash
# Check VM status
mvm status vm-name

# Get detailed VM information
mvm info vm-name

# Check VM IP address
mvm ip vm-name

# Test direct shell access
mvm shell vm-name
```

## Completion Support

The script includes bash and zsh completion support:
- **Bash**: `share/completions/mvm.bash`
- **Zsh**: `share/completions/_mvm`

Completions provide:
- Command completion
- VM name completion
- Distribution completion
- Username completion for SSH
- Directory completion for mounting
