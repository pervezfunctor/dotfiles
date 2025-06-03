# dt - Distrobox Container Management Script

The `dt` script provides a unified interface for managing distrobox containers, similar to how the `vm` script manages virtual machines. It offers a consistent command-line experience for creating, managing, and interacting with distrobox containers.

## Features

- **Container Lifecycle Management**: Create, start, stop, restart, and delete containers
- **Interactive Operations**: Enter containers, run commands, view status and logs
- **Application Export**: Export and unexport applications from containers
- **Cleanup Operations**: Remove stopped containers and orphaned files
- **Integration**: Works with existing distrobox functions from `share/fns`

## Commands

### Installation
- `dt install` - Install container tools (distrobox, podman, docker, etc.) using ilm-installer

### Basic Operations
- `dt list` - List all distrobox containers
- `dt status <name>` - Show detailed container status and info
- `dt create <distro> [name]` - Create a new distrobox container
- `dt start <name>` - Start a container
- `dt stop <name>` - Stop a container
- `dt restart <name>` - Restart a container
- `dt delete <name>` - Delete a container completely (with confirmation)

### Interactive Operations
- `dt enter <name>` - Enter container shell
- `dt run <name> <command>` - Run command in container
- `dt logs <name>` - Show container logs

### Application Management
- `dt export <name> <app>` - Export application from container to host
- `dt unexport <app>` - Remove exported application

### Maintenance
- `dt upgrade <name>` - Upgrade packages in container
- `dt cleanup` - Remove stopped containers and orphaned files

## Supported Distributions

The script supports creating containers for the following distributions:
- ubuntu, debian, arch, fedora, rocky, tumbleweed, alpine
- bluefin, docker, wolfi, nix

## Examples

```bash
# Install container tools
dt install

# List all containers
dt list

# Create an Ubuntu container with default name
dt create ubuntu

# Create a Fedora container with custom name
dt create fedora my-fedora

# Enter a container
dt enter ubuntu

# Run a command in a container
dt run ubuntu "apt update && apt install -y vim"

# Export Firefox from Ubuntu container
dt export ubuntu firefox

# Show container status
dt status ubuntu

# Upgrade packages in container
dt upgrade ubuntu

# Clean up stopped containers
dt cleanup

# Delete a container (with confirmation)
dt delete old-container
```

## Installation

The script includes a built-in installation command that uses `ilm-installer` to install container tools:

```bash
# Install container tools automatically
dt install
```

This command will:
- Install distrobox package for your distribution
- Install container engines (Podman, Docker)
- Install additional container tools (Incus, Buildah)
- Configure services and user permissions
- Set up container management tools (Cockpit, Portainer)

The installation includes:
- **distrobox** - Main container management tool
- **podman** - Rootless container engine
- **docker** - Traditional container engine
- **incus** - System containers and VMs
- **buildah** - Container image building
- **cockpit** - Web-based container management
- **portainer** - Docker container management UI

## Integration with Existing Functions

The script automatically sources and uses existing distrobox creation functions from `share/fns` when available, including:
- `dbox-ubuntu`, `dbox-debian`, `dbox-arch`, etc.
- Special containers like `dbox-docker`, `dbox-bluefin`, `dbox-nix`

## Container Storage

Containers are created with dedicated home directories in `$HOME/.boxes/<container-name>` to keep container data organized and separate from the host system.

## Error Handling

The script includes comprehensive error handling:
- Validates container existence before operations
- Provides clear error messages and usage information
- Handles missing dependencies gracefully
- Confirms destructive operations

## Comparison with VM Script

| Feature         | `vm` (Virtual Machines)       | `dt` (Distrobox)              |
| --------------- | ----------------------------- | ----------------------------- |
| List            | `vm list`                     | `dt list`                     |
| Status          | `vm status <name>`            | `dt status <name>`            |
| Create          | `vm create --distro <distro>` | `dt create <distro> [name]`   |
| Start           | `vm start <name>`             | `dt start <name>`             |
| Stop            | `vm stop <name>`              | `dt stop <name>`              |
| Delete          | `vm delete <name>`            | `dt delete <name>`            |
| Connect         | `vm ssh <name>`               | `dt enter <name>`             |
| Run Command     | `vm ssh <name> "command"`     | `dt run <name> "command"`     |
| Cleanup         | `vm cleanup`                  | `dt cleanup`                  |
| Unique Features | Console, IP, Autostart        | Export/Unexport apps, Upgrade |

This provides a consistent interface across both virtualization technologies while respecting their unique capabilities.
