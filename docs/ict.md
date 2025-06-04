# ict - Incus LXC Container Management Script

The `ict` script provides a unified interface for managing Incus LXC containers, similar to how the `dt` script manages distrobox containers and the `ivm` script manages Incus VMs. It offers a consistent command-line experience for creating, managing, and interacting with Incus LXC containers.

## Features

- **Container Lifecycle Management**: Create, start, stop, restart, and delete containers
- **Interactive Operations**: Shell access, command execution, status monitoring
- **Incus-Specific Features**: Snapshots, container copying, detailed configuration management
- **Cleanup Operations**: Remove stopped containers and manage resources
- **Integration**: Works with existing Incus container creation functions from `share/fns`

## Commands

### Basic Operations
- `ict list` - List all Incus containers
- `ict status <name>` - Show container status and basic info
- `ict create <distro> [name]` - Create a new Incus container
- `ict start <name>` - Start a container
- `ict stop <name>` - Stop a container
- `ict restart <name>` - Restart a container
- `ict delete <name>` - Delete a container completely (with confirmation)

### Interactive Operations
- `ict shell <name>` - Enter container shell
- `ict exec <name> <command>` - Execute command in container

### Network Operations
- `ict ip <name>` - Get container IP address
- `ict ssh <name> [username]` - Connect to container via SSH

### Information and Configuration
- `ict info <name>` - Show detailed container information
- `ict config <name>` - Show container configuration

### Snapshot Management
- `ict snapshot <name> [snapshot-name]` - Create container snapshot
- `ict restore <name> <snapshot-name>` - Restore container from snapshot

### Advanced Operations
- `ict copy <source> <destination>` - Copy container
- `ict cleanup` - Remove stopped containers

## Supported Distributions

The script supports creating containers for the following distributions:
- ubuntu, fedora, arch, tumbleweed, debian, centos, alpine

## Examples

```bash
# List all containers
ict list

# Create an Ubuntu container with default name
ict create ubuntu

# Create a Fedora container with custom name
ict create fedora my-fedora-ct

# Start a container
ict start ubuntu

# Enter container shell
ict shell ubuntu

# Execute a command in container
ict exec ubuntu "apt update && apt install -y vim"

# Get container IP address
ict ip ubuntu

# SSH to container (auto-detect username)
ict ssh ubuntu

# SSH to container with specific username
ict ssh ubuntu root

# Show detailed container information
ict info ubuntu

# Create a snapshot
ict snapshot ubuntu before-update

# Restore from snapshot
ict restore ubuntu before-update

# Copy a container
ict copy ubuntu ubuntu-backup

# Show container configuration
ict config ubuntu

# Clean up stopped containers
ict cleanup

# Delete a container (with confirmation)
ict delete old-container
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
- `ict shell <name>` connects directly to container shell
- No network configuration required
- Works immediately after container creation

### Command Execution
Execute commands directly in containers:
- `ict exec <name> <command>` runs commands without SSH
- Useful for automation and quick tasks
- No authentication setup required

### Network Access
IP discovery and SSH connectivity:
- `ict ip <name>` gets container IP address using multiple detection methods
- `ict ssh <name>` connects via SSH with automatic username detection
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

| Feature         | `dt` (Distrobox)      | `ict` (Incus LXC)       | `ivm` (Incus VM)        | `vm` (libvirt)                |
| --------------- | --------------------- | ----------------------- | ----------------------- | ----------------------------- |
| List            | `dt list`             | `ict list`              | `ivm list`              | `vm list`                     |
| Status          | `dt status <name>`    | `ict status <name>`     | `ivm status <name>`     | `vm status <name>`            |
| Create          | `dt create <distro>`  | `ict create <distro>`   | `ivm create <distro>`   | `vm create --distro <distro>` |
| Start           | `dt start <name>`     | `ict start <name>`      | `ivm start <name>`      | `vm start <name>`             |
| Stop            | `dt stop <name>`      | `ict stop <name>`       | `ivm stop <name>`       | `vm stop <name>`              |
| Connect         | `dt enter <name>`     | `ict shell <name>`      | `ivm console <name>`    | `vm ssh <name>`               |
| Execute         | `dt run <name> "cmd"` | `ict exec <name> "cmd"` | `ivm exec <name> "cmd"` | `vm ssh <name> "cmd"`         |
| IP Address      | N/A                   | `ict ip <name>`         | `ivm ip <name>`         | `vm ip <name>`                |
| SSH Access      | N/A                   | `ict ssh <name>`        | `ivm ssh <name>`        | `vm ssh <name>`               |
| Delete          | `dt delete <name>`    | `ict delete <name>`     | `ivm delete <name>`     | `vm delete <name>`            |
| Unique Features | App export/import     | Snapshots, Copy, Config | Snapshots, Copy, Config | Advanced SSH features         |

## Container vs VM Trade-offs

### Incus LXC Containers (`ict`)
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

### Incus VMs (`ivm`)
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
