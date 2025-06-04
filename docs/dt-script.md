# dt - Distrobox Container Management Script

The `dt` script provides a unified interface for managing distrobox containers, similar to how the `vm` script manages virtual machines. It offers a consistent command-line experience for creating, managing, and interacting with distrobox containers.

## Features

- **Container Lifecycle Management**: Create, start, stop, restart, and delete containers
- **Interactive Operations**: Enter containers, run commands, view status and logs
- **Application Export**: Export and unexport applications from containers
- **Cleanup Operations**: Remove stopped containers and orphaned files
- **Integration**: Works with existing distrobox functions
- **Fallback Mechanism**: Gracefully handles missing utility functions

## Commands

### Installation
- `dt install` - Install container tools (distrobox, podman, docker, etc.) using ilmi

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
- `dt logs-tail <name>` - Follow container logs (like tail -f)

### Application Management
- `dt export <name> <app>` - Export application from container to host
- `dt unexport <app>` - Remove exported application

### Maintenance
- `dt upgrade <name>` - Upgrade packages in container
- `dt cleanup` - Remove stopped containers and orphaned files

## Supported Distributions

The script supports creating containers for the following distributions:
- **Ubuntu**: Latest Ubuntu release
- **Debian**: Latest Debian release
- **Arch Linux**: Latest Arch Linux release
- **Fedora**: Latest Fedora release
- **Rocky Linux**: Rocky Linux 9
- **openSUSE Tumbleweed**: Latest rolling release
- **Alpine**: Latest Alpine Linux release
- **Bluefin**: UBlue OS Bluefin CLI image
- **Docker**: Container with Docker-in-Docker support
- **Wolfi**: Wolfi SDK container
- **Nix**: NixOS container

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

# Follow container logs
dt logs-tail ubuntu

# Clean up stopped containers
dt cleanup

# Delete a container (with confirmation)
dt delete old-container
```

## Installation

The script includes a built-in installation command that uses `ilmi` to install container tools:

```bash
# Install container tools automatically
dt install
```

This command will:
- Install distrobox package for your distribution
- Install container engines (Podman, Docker)
- Configure services and user permissions

## Container Storage

Containers are created with dedicated home directories in `$HOME/.boxes/<container-name>` to keep container data organized and separate from the host system.

## Error Handling

The script includes comprehensive error handling:
- Validates container existence before operations
- Provides clear error messages and usage information
- Handles missing dependencies gracefully
- Confirms destructive operations
- Gracefully handles missing utility functions

## Comparison with Other Container/VM Scripts

| Feature         | `dt` (Distrobox)              | `vm` (Virtual Machines)       | `ict` (Incus)           | `ivm` (Incus)           |
| --------------- | ----------------------------- | ----------------------------- | ----------------------- | ----------------------- |
| List            | `dt list`                     | `vm list`                     | `ict list`              | `ivm list`              |
| Status          | `dt status <name>`            | `vm status <name>`            | `ict status <name>`     | `ivm status <name>`     |
| Create          | `dt create <distro> [name]`   | `vm create --distro <distro>` | `ict create <distro>`   | `ivm create <distro>`   |
| Start           | `dt start <name>`             | `vm start <name>`             | `ict start <name>`      | `ivm start <name>`      |
| Stop            | `dt stop <name>`              | `vm stop <name>`              | `ict stop <name>`       | `ivm stop <name>`       |
| Delete          | `dt delete <name>`            | `vm delete <name>`            | `ict delete <name>`     | `ivm delete <name>`     |
| Connect         | `dt enter <name>`             | `vm ssh <name>`               | `ict shell <name>`      | `ivm console <name>`    |
| Run Command     | `dt run <name> "command"`     | `vm ssh <name> "command"`     | `ict exec <name> "cmd"` | `ivm exec <name> "cmd"` |
| Logs            | `dt logs <name>`              | `vm logs <name>`              | `ict logs <name>`       | `ivm logs <name>`       |
| Cleanup         | `dt cleanup`                  | `vm cleanup`                  | `ict cleanup`           | `ivm cleanup`           |
| Unique Features | Export/Unexport apps, Upgrade | Console, IP, Autostart        | Snapshots, Copy, Config | Snapshots, Copy, Config |

This provides a consistent interface across different containerization and virtualization technologies while respecting their unique capabilities.
