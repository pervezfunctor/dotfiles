# ICT - Incus Container Tools

The ICT (Incus Container Tools) suite provides a comprehensive set of utilities for managing Incus LXC containers. It consists of two main components:

- **`ict`** - A unified interface for managing Incus LXC containers throughout their lifecycle
- **`ict-create`** - A specialized tool for creating new Incus LXC containers with cloud-init configuration

These tools provide a consistent, user-friendly interface for container operations, similar to how `dt` manages Distrobox containers and `ivm` manages Incus VMs.

## Quick Start

```bash
# Create a new Ubuntu container
ict-create --distro ubuntu --name my-ubuntu

# List all containers
ict list

# Start the container
ict start my-ubuntu

# Enter the container shell
ict shell my-ubuntu

# Get container IP address
ict ip my-ubuntu

# SSH into the container
ict ssh my-ubuntu
```

## Installation

The ICT tools are located in `bin/vt/`:

- `bin/vt/ict` - Container management script
- `bin/vt/ict-create` - Container creation script
- `bin/vt/ict-utils` - Shared utility functions

Ensure these scripts are in your PATH and that you have Incus installed and configured with proper user permissions.

## Prerequisites

- Incus installed and running
- User added to `incus` and `incus-admin` groups
- SSH key pair (auto-generated if missing)
- Proper network configuration for container access

---

# ict - Container Management Tool

The `ict` script provides a comprehensive interface for managing Incus LXC containers throughout their lifecycle.

## Commands Overview

### Basic Operations
- `ict list` - List all Incus containers
- `ict list-remote-images` - List all remote images available for container creation
- `ict status <name>` - Show container status and info
- `ict create [ict-create args]` - Create a new Incus container (forwards all args to ict-create)
- `ict start <name>` - Start a container
- `ict stop <name>` - Stop a container
- `ict restart <name>` - Restart a container
- `ict delete <name>` - Delete a container completely

### Interactive Operations
- `ict shell <name>` - Enter container shell
- `ict exec <name> <cmd>` - Execute command in container
- `ict ssh <name> [username]` - Connect to container via SSH

### Information and Configuration
- `ict ip <name>` - Get container IP address
- `ict info <name>` - Show detailed container information
- `ict config <name>` - Show container configuration
- `ict logs <name> [type]` - Show container logs (instance, console, or system)

### Advanced Operations
- `ict snapshot <name> [snap]` - Create container snapshot
- `ict restore <name> <snap>` - Restore container from snapshot
- `ict copy <src> <dest>` - Copy container

### USB Device Management
- `ict usb-list` - List all available USB devices on host
- `ict usb-attached <name>` - List USB devices attached to container
- `ict usb-attach <name> <device> [device-name]` - Attach USB device to container
- `ict usb-detach <name> <device>` - Detach USB device from container

## Usage Examples

```bash
# List all containers
ict list

# Show status of a specific container
ict status ubuntu

# Create a new container (forwards to ict-create)
ict create --distro ubuntu --name myubuntu

# Start and enter a container
ict start ubuntu
ict shell ubuntu

# Execute commands in a container
ict exec ubuntu "ls -la"
ict exec ubuntu "apt update && apt upgrade -y"

# Get container IP and SSH access
ict ip ubuntu
ict ssh ubuntu
ict ssh ubuntu root

# View container information
ict info ubuntu
ict config ubuntu

# Work with logs
ict logs ubuntu
ict logs ubuntu console
ict logs ubuntu system

# Snapshot management
ict snapshot ubuntu backup
ict restore ubuntu backup

# Copy containers
ict copy ubuntu ubuntu-backup

# USB device management
ict usb-list
ict usb-attach ubuntu 1234:5678
ict usb-attached ubuntu
ict usb-detach ubuntu my-usb

# Delete a container
ict delete old-container
```

## Key Features

### Automatic User Detection
The `ict shell` and `ict ssh` commands automatically detect the appropriate username based on container naming patterns:
- `ubuntu*` → `ubuntu`
- `fedora*` → `fedora`
- `centos*` → `centos`
- `debian*` → `debian`
- `arch*` → `arch`
- `tumbleweed*` or `tw*` → `opensuse`

### Comprehensive Log Access
Access different types of container logs:
- **Instance logs**: Container instance information and events
- **Console logs**: Console output and boot messages
- **System logs**: System journal and log files

### USB Device Management
Full USB device passthrough support:
- List available USB devices on the host
- Attach devices by vendor:product ID or bus.device notation
- Manage attached devices per container
- Automatic device naming with timestamps

### Error Handling
The script includes comprehensive error handling:
- Validates Incus installation and permissions
- Checks container existence before operations
- Provides clear error messages and usage information
- Confirms destructive operations (delete, restore)
- Handles missing dependencies gracefully

---

# ict-create - Container Creation Tool

The `ict-create` script creates Incus LXC containers with cloud-init configuration and SSH access enabled.

## Usage

```bash
ict-create --distro DISTRO [OPTIONS]
```

### Required Arguments
- `--distro DISTRO` - Distribution to install (ubuntu, fedora, arch, debian, centos, tumbleweed, alpine)

### Optional Arguments
- `--name NAME` - Container name (default: distro name)
- `--release RELEASE` - Distribution release (default: latest)
- `--username USER` - Username for container (default: distro default)
- `--password PASS` - User password (default: username)
- `--vcpus NUM` - Number of vCPUs (default: 2)
- `--memory MB` - RAM in MB (default: 2048)
- `--ssh-key PATH` - SSH public key path (default: auto-detect)
- `--privileged` - Create privileged container (default: false)

## Supported Distributions

| Distribution | Default Release | Default User | Image Source                     |
| ------------ | --------------- | ------------ | -------------------------------- |
| Ubuntu       | plucky/25.04    | ubuntu       | images:ubuntu/plucky/cloud       |
| Fedora       | 42              | fedora       | images:fedora/42/cloud           |
| Arch Linux   | current         | arch         | images:archlinux/current/cloud   |
| Debian       | 13/trixie       | debian       | images:debian/13/cloud           |
| CentOS       | 9-Stream        | centos       | images:centos/9-Stream/cloud     |
| openSUSE     | current         | opensuse     | images:opensuse/tumbleweed/cloud |
| Alpine       | 3.22            | alpine       | images:alpine/3.22/cloud         |

## Creation Examples

```bash
# Basic container creation
ict-create --distro ubuntu
ict-create --distro fedora --name my-fedora
ict-create --distro debian --username admin --password mypass

# Resource customization
ict-create --distro ubuntu --vcpus 4 --memory 4096
ict-create --distro alpine --vcpus 1 --memory 512

# Advanced configuration
ict-create --distro ubuntu --privileged
ict-create --distro arch --ssh-key ~/.ssh/custom_key.pub
ict-create --distro fedora --release 40

# Complex example with dotfiles and Docker
ict-create --distro fedora --name dev-container --vcpus 4 --memory 4096 --privileged
```

## Cloud-init Configuration

The script automatically configures containers with:

### User Setup
- Creates user with specified username and password
- Adds user to sudo/wheel/adm groups
- Configures passwordless sudo access
- Sets up SSH key authentication
- Configures proper shell environment

### System Configuration
- Updates package repositories and upgrades packages
- Installs essential packages:
  - openssh-server (or openssh for Arch)
  - curl, wget, vim, htop, git, unzip
- Enables SSH service automatically
- Configures hostname and hosts file
- Sets up proper message of the day

### Network Configuration
- Configures DHCP networking
- Sets up proper hostname resolution
- Enables systemd-resolved when available

## Container Types

### Unprivileged Containers (Default)
- **Security**: Better isolation, runs as unprivileged user
- **Use Cases**: General development, testing, web services
- **Limitations**: Cannot run Docker, some system operations restricted

### Privileged Containers (--privileged flag)
- **Security**: Less isolation, runs as root
- **Use Cases**: Docker-in-container, system administration, legacy apps
- **Capabilities**: Full system access, can run Docker and systemd

## Post-Creation Access

After container creation, you can access the container using:

```bash
# Get container IP address
ict ip container-name

# SSH access (auto-detects username)
ict ssh container-name

# Direct shell access
ict shell container-name

# Execute commands
ict exec container-name "command"

# View container information
ict info container-name
ict status container-name
```

---

# Integration and Workflow

## Typical Workflow

1. **Create Container**:
   ```bash
   ict-create --distro ubuntu --name dev-env --vcpus 4 --memory 4096
   ```

2. **Start and Access**:
   ```bash
   ict start dev-env
   ict shell dev-env
   ```

3. **Development Work**:
   ```bash
   # Install development tools
   ict exec dev-env "apt update && apt install -y build-essential nodejs"

   # Copy files to container
   ict exec dev-env -- mkdir -p /workspace
   # (Use incus file push/pull for file operations)
   ```

4. **Snapshot Before Changes**:
   ```bash
   ict snapshot dev-env before-upgrade
   ```

5. **Manage Container Lifecycle**:
   ```bash
   ict stop dev-env
   ict start dev-env
   ict restart dev-env
   ```

6. **Cleanup**:
   ```bash
   ict delete dev-env
   ```

## Integration with Other Tools

The ICT tools integrate seamlessly with other container and VM management tools:

| Feature   | `ict` (LXC)    | `ivm` (VM)     | `dt` (Distrobox) |
| --------- | -------------- | -------------- | ---------------- |
| List      | `ict list`     | `ivm list`     | `dt list`        |
| Create    | `ict create`   | `ivm create`   | `dt create`      |
| Start     | `ict start`    | `ivm start`    | `dt start`       |
| Stop      | `ict stop`     | `ivm stop`     | `dt stop`        |
| Access    | `ict shell`    | `ivm console`  | `dt enter`       |
| Execute   | `ict exec`     | `ivm exec`     | `dt run`         |
| SSH       | `ict ssh`      | `ivm ssh`      | N/A              |
| IP        | `ict ip`       | `ivm ip`       | N/A              |
| Snapshots | `ict snapshot` | `ivm snapshot` | N/A              |
| Delete    | `ict delete`   | `ivm delete`   | `dt delete`      |

## Performance Characteristics

### Container vs VM Comparison

| Aspect          | LXC Container    | Virtual Machine         |
| --------------- | ---------------- | ----------------------- |
| Startup Time    | 1-3 seconds      | 30-60 seconds           |
| Memory Overhead | ~10-50MB         | ~500MB+                 |
| Disk Usage      | Shared with host | Separate disk image     |
| Performance     | Near-native      | Virtualization overhead |
| Isolation       | Process-level    | Hardware-level          |
| Kernel          | Shared with host | Separate kernel         |

### Resource Efficiency
- **CPU**: Direct access to host CPU, no virtualization overhead
- **Memory**: Efficient memory sharing with host
- **I/O**: Direct filesystem access, faster than VM disk images
- **Network**: Efficient bridge networking

---

# Troubleshooting

## Common Issues

### Container Creation Problems
```bash
# Check Incus status
systemctl status incus

# Verify user permissions
groups $USER  # Should include incus and incus-admin

# Check available images
incus image list images:

# Test basic functionality
incus list
```

### Network and SSH Issues
```bash
# Check container IP
ict ip container-name

# Verify network connectivity
ict exec container-name -- ping 8.8.8.8

# Check SSH service
ict exec container-name -- systemctl status ssh

# Test SSH manually
ssh username@container-ip
```

### USB Device Issues
```bash
# List available USB devices
ict usb-list

# Check attached devices
ict usb-attached container-name

# Verify USB device specification
lsusb  # Shows vendor:product IDs
```

### Log Analysis
```bash
# Check different log types
ict logs container-name
ict logs container-name console
ict logs container-name system

# Check cloud-init status
ict exec container-name -- cloud-init status
```

## Error Messages and Solutions

| Error                            | Cause                   | Solution                             |
| -------------------------------- | ----------------------- | ------------------------------------ |
| "Container not found"            | Container doesn't exist | Check name with `ict list`           |
| "Container is not running"       | Container stopped       | Start with `ict start name`          |
| "Could not determine IP address" | Network not ready       | Wait longer, check networking        |
| "Permission denied"              | User not in incus group | Add user to incus/incus-admin groups |
| "SSH connection failed"          | SSH not running         | Check SSH service status             |

---

# Advanced Usage

## Custom Configurations

### Resource Limits
```bash
# Create resource-intensive container
ict-create --distro ubuntu --name build-server --vcpus 8 --memory 8192

# Create minimal container
ict-create --distro alpine --name test --vcpus 1 --memory 256
```

### Privileged Containers for Docker
```bash
# Create Docker host container
ict-create --distro ubuntu --name docker-host --privileged

# Install Docker inside
ict exec docker-host -- curl -fsSL https://get.docker.com | sh
```

### Development Environments
```bash
# Create development environment
ict-create --distro fedora --name dev-env --vcpus 4 --memory 4096

# Set up development tools
ict exec dev-env -- dnf groupinstall -y "Development Tools"
ict exec dev-env -- dnf install -y nodejs python3 git
```

## Automation and Scripting

### Batch Operations
```bash
# Create multiple containers
for distro in ubuntu fedora debian; do
    ict-create --distro $distro --name $distro-test
done

# Start all containers
for container in $(ict list | grep -E "^\w+" | awk '{print $2}'); do
    ict start $container
done
```

### Backup and Restore
```bash
# Create snapshots of all containers
for container in $(ict list | grep -E "^\w+" | awk '{print $2}'); do
    ict snapshot $container backup-$(date +%Y%m%d)
done

# Restore from snapshot
ict restore container-name snapshot-name
```

## Security Considerations

### Container Isolation
- Use unprivileged containers for most workloads
- Reserve privileged containers for specific needs (Docker, system tools)
- Regularly update containers and host system

### SSH Security
- Use SSH key authentication instead of passwords
- Consider disabling password authentication in production
- Use firewall rules to restrict container access

### Resource Management
- Set appropriate resource limits to prevent resource exhaustion
- Monitor container resource usage
- Use snapshots for backup before major changes

---

# Comparison with Other Solutions

## ICT vs Docker

| Feature            | ICT (Incus LXC)      | Docker                 |
| ------------------ | -------------------- | ---------------------- |
| Isolation          | Process-level        | Application-level      |
| System Services    | Full systemd support | Limited                |
| Multiple Processes | Full OS              | Single process model   |
| SSH Access         | Native               | Requires configuration |
| Snapshots          | Built-in             | Limited                |
| Resource Limits    | Fine-grained         | Basic                  |
| Desktop Apps       | Full support         | Limited                |

## ICT vs Distrobox

| Feature             | ICT (Incus LXC) | Distrobox         |
| ------------------- | --------------- | ----------------- |
| Backend             | Incus           | Podman/Docker     |
| Integration         | System-level    | Application-level |
| Desktop Integration | Basic           | Full              |
| Performance         | Near-native     | Good              |
| Snapshots           | Built-in        | No                |
| USB Passthrough     | Full support    | Limited           |

## ICT vs VMs

| Feature        | ICT (LXC)           | VM                  |
| -------------- | ------------------- | ------------------- |
| Startup Time   | Seconds             | Minutes             |
| Resource Usage | Minimal             | Significant         |
| Performance    | Near-native         | Virtualized         |
| Isolation      | Process-level       | Hardware-level      |
| Kernel         | Shared              | Separate            |
| Use Case       | Development/Testing | Production/Security |

---

# Contributing and Support

## File Structure

```
bin/vt/
├── ict           # Main container management script
├── ict-create    # Container creation script
├── ict-utils     # Shared utility functions
└── ...           # Other related tools

docs/ict/
└── README.md     # This documentation
```

## Dependencies

The ICT tools depend on:
- Incus (container management)
- OpenSSL (password hashing)
- Standard Unix utilities (lsusb, etc.)
- SSH client and server

## Getting Help

For issues and questions:
1. Check this documentation
2. Review the script help: `ict --help` and `ict-create --help`
3. Check Incus documentation: https://linuxcontainers.org/incus/docs/
4. Review logs and error messages for troubleshooting

## Best Practices

1. **Naming**: Use descriptive container names that indicate purpose
2. **Resources**: Allocate appropriate resources based on workload
3. **Snapshots**: Create snapshots before major changes
4. **Security**: Use unprivileged containers when possible
5. **Backups**: Regularly backup important container data
6. **Monitoring**: Monitor container resource usage and performance
7. **Updates**: Keep containers and host system updated

The ICT tools provide a powerful, flexible solution for managing Incus LXC containers with the convenience of a unified interface and the power of underlying Incus capabilities.
