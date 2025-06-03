# incus-ct - Incus LXC Container Management Script

The `incus-ct` script provides a unified interface for managing Incus LXC containers, similar to how the `dt` script manages distrobox containers and the `incus-vm` script manages Incus VMs. It offers a consistent command-line experience for creating, managing, and interacting with Incus LXC containers.

## Features

- **Container Lifecycle Management**: Create, start, stop, restart, and delete containers
- **Interactive Operations**: Shell access, command execution, status monitoring
- **Incus-Specific Features**: Snapshots, container copying, detailed configuration management
- **Cleanup Operations**: Remove stopped containers and manage resources
- **Integration**: Works with existing Incus container creation functions from `share/fns`

## Commands

### Basic Operations
- `incus-ct list` - List all Incus containers
- `incus-ct status <name>` - Show container status and basic info
- `incus-ct create <distro> [name]` - Create a new Incus container
- `incus-ct start <name>` - Start a container
- `incus-ct stop <name>` - Stop a container
- `incus-ct restart <name>` - Restart a container
- `incus-ct delete <name>` - Delete a container completely (with confirmation)

### Interactive Operations
- `incus-ct shell <name>` - Enter container shell
- `incus-ct exec <name> <command>` - Execute command in container

### Network Operations
- `incus-ct ip <name>` - Get container IP address
- `incus-ct ssh <name> [username]` - Connect to container via SSH

### Information and Configuration
- `incus-ct info <name>` - Show detailed container information
- `incus-ct config <name>` - Show container configuration

### Snapshot Management
- `incus-ct snapshot <name> [snapshot-name]` - Create container snapshot
- `incus-ct restore <name> <snapshot-name>` - Restore container from snapshot

### Advanced Operations
- `incus-ct copy <source> <destination>` - Copy container
- `incus-ct cleanup` - Remove stopped containers

## Supported Distributions

The script supports creating containers for the following distributions:
- ubuntu, fedora, arch, tumbleweed, debian, centos, alpine

## Examples

```bash
# List all containers
incus-ct list

# Create an Ubuntu container with default name
incus-ct create ubuntu

# Create a Fedora container with custom name
incus-ct create fedora my-fedora-ct

# Start a container
incus-ct start ubuntu

# Enter container shell
incus-ct shell ubuntu

# Execute a command in container
incus-ct exec ubuntu "apt update && apt install -y vim"

# Get container IP address
incus-ct ip ubuntu

# SSH to container (auto-detect username)
incus-ct ssh ubuntu

# SSH to container with specific username
incus-ct ssh ubuntu root

# Show detailed container information
incus-ct info ubuntu

# Create a snapshot
incus-ct snapshot ubuntu before-update

# Restore from snapshot
incus-ct restore ubuntu before-update

# Copy a container
incus-ct copy ubuntu ubuntu-backup

# Show container configuration
incus-ct config ubuntu

# Clean up stopped containers
incus-ct cleanup

# Delete a container (with confirmation)
incus-ct delete old-container
```

## Integration with Existing Functions

The script automatically sources and uses existing Incus container creation functions from `share/fns` when available, including:
- `incus-ubuntu-lxc`, `incus-fedora-lxc`, `incus-arch-lxc`, etc.

If these functions aren't available, it falls back to direct `incus launch` commands with appropriate image names.

## Key Features

### Lightweight Containers
LXC containers are more lightweight than VMs:
- Faster startup times
- Lower resource overhead
- Shared kernel with host
- Near-native performance

### Snapshot Management
Like Incus VMs, containers provide excellent snapshot capabilities:
- Automatic snapshot naming with timestamps
- Easy restore with confirmation prompts
- Snapshot-based container copying

### Direct Shell Access
Direct shell access without SSH setup:
- `incus-ct shell <name>` connects directly to container shell
- No network configuration required
- Works immediately after container creation

### Command Execution
Execute commands directly in containers:
- `incus-ct exec <name> <command>` runs commands without SSH
- Useful for automation and quick tasks
- No authentication setup required

### Network Access
IP discovery and SSH connectivity:
- `incus-ct ip <name>` gets container IP address using multiple detection methods
- `incus-ct ssh <name>` connects via SSH with automatic username detection
- Supports both distro-specific users and root access
- Fallback to root for containers (typical container pattern)

## Error Handling

The script includes comprehensive error handling:
- Validates Incus installation before operations
- Checks container existence before operations
- Provides clear error messages and usage information
- Confirms destructive operations (delete, restore)
- Handles missing dependencies gracefully

## Comparison with Other Container/VM Scripts

| Feature         | `dt` (Distrobox)      | `incus-ct` (Incus LXC)       | `incus-vm` (Incus VM)        | `vm` (libvirt)                |
| --------------- | --------------------- | ---------------------------- | ---------------------------- | ----------------------------- |
| List            | `dt list`             | `incus-ct list`              | `incus-vm list`              | `vm list`                     |
| Status          | `dt status <name>`    | `incus-ct status <name>`     | `incus-vm status <name>`     | `vm status <name>`            |
| Create          | `dt create <distro>`  | `incus-ct create <distro>`   | `incus-vm create <distro>`   | `vm create --distro <distro>` |
| Start           | `dt start <name>`     | `incus-ct start <name>`      | `incus-vm start <name>`      | `vm start <name>`             |
| Stop            | `dt stop <name>`      | `incus-ct stop <name>`       | `incus-vm stop <name>`       | `vm stop <name>`              |
| Connect         | `dt enter <name>`     | `incus-ct shell <name>`      | `incus-vm console <name>`    | `vm ssh <name>`               |
| Execute         | `dt run <name> "cmd"` | `incus-ct exec <name> "cmd"` | `incus-vm exec <name> "cmd"` | `vm ssh <name> "cmd"`         |
| IP Address      | N/A                   | `incus-ct ip <name>`         | `incus-vm ip <name>`         | `vm ip <name>`                |
| SSH Access      | N/A                   | `incus-ct ssh <name>`        | `incus-vm ssh <name>`        | `vm ssh <name>`               |
| Delete          | `dt delete <name>`    | `incus-ct delete <name>`     | `incus-vm delete <name>`     | `vm delete <name>`            |
| Unique Features | App export/import     | Snapshots, Copy, Config      | Snapshots, Copy, Config      | Advanced SSH features         |

## Container vs VM Trade-offs

### Incus LXC Containers (`incus-ct`)
**Advantages:**
- Faster startup (seconds)
- Lower resource usage
- Better performance
- Easier file sharing with host

**Use Cases:**
- Development environments
- Testing different distributions
- Running services
- CI/CD environments

### Incus VMs (`incus-vm`)
**Advantages:**
- Complete isolation
- Different kernels
- Security boundaries
- Full OS simulation

**Use Cases:**
- Security testing
- Different OS versions
- Kernel development
- Production-like environments

## Prerequisites

- Incus installed and configured
- User added to `incus` and `incus-admin` groups
- Incus daemon running

## Installation Notes

The script integrates with the existing Incus installation functions in `share/installers/` which handle:
- Package installation
- User group configuration
- Service enablement
- Firewall configuration (if needed)
- Initial Incus setup

This provides a consistent interface across different containerization and virtualization technologies while leveraging Incus's unique capabilities for both containers and VMs.
