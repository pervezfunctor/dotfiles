# ict-create - Incus LXC Container Creation Script

The `ict-create` script creates Incus LXC containers with cloud-init configuration and SSH access enabled. It provides a streamlined way to create lightweight containers with proper user setup, SSH key authentication, and essential packages pre-installed.

## Features

- **Cloud-init Integration**: Automatic container configuration using cloud-init
- **SSH Access**: Pre-configured SSH access with public key authentication
- **User Management**: Creates user with sudo privileges and password authentication
- **Multiple Distributions**: Support for Ubuntu, Fedora, Arch, Debian, CentOS, and Alpine
- **Resource Configuration**: Customizable CPU and memory allocation
- **Privileged Containers**: Option to create privileged containers when needed
- **Automatic Setup**: Installs essential packages and enables services
- **SSH Key Management**: Auto-detects or generates SSH keys

## Usage

```bash
ict-create --distro DISTRO [OPTIONS]
```

### Required Arguments

- `--distro DISTRO` - Distribution to install (ubuntu, fedora, arch, debian, centos, alpine)

### Optional Arguments

- `--name NAME` - Container name (default: distribution name)
- `--release RELEASE` - Distribution release (default: latest stable)
- `--username USER` - Username for container (default: distribution default)
- `--password PASS` - User password (default: container name)
- `--vcpus NUM` - Number of vCPUs (default: 2)
- `--ram MB` - RAM in MB (default: 1024)
- `--ssh-key PATH` - SSH public key path (default: auto-detect)
- `--privileged` - Create privileged container (default: false)

## Examples

### Basic Container Creation
```bash
# Create Ubuntu container with defaults
ict-create --distro ubuntu

# Create Fedora container with custom name
ict-create --distro fedora --name my-fedora

# Create Debian container with custom user
ict-create --distro debian --username admin --password mypass
```

### Resource Customization
```bash
# Create container with more resources
ict-create --distro ubuntu --vcpus 4 --ram 2048

# Create minimal container
ict-create --distro alpine --vcpus 1 --ram 512
```

### Advanced Configuration
```bash
# Create privileged container (for Docker, etc.)
ict-create --distro ubuntu --privileged

# Use specific release
ict-create --distro ubuntu --release 22.04

# Use custom SSH key
ict-create --distro arch --ssh-key ~/.ssh/my_key.pub
```

## Supported Distributions

| Distribution | Default Release | Default User | Image Source             |
| ------------ | --------------- | ------------ | ------------------------ |
| Ubuntu       | 24.04           | ubuntu       | images:ubuntu/24.04      |
| Fedora       | 43              | fedora       | images:fedora/42         |
| Arch Linux   | current         | arch         | images:archlinux/current |
| Debian       | 12              | debian       | images:debian/12         |
| CentOS       | 9-Stream        | centos       | images:centos/9-Stream   |
| Alpine       | 3.19            | alpine       | images:alpine/3.19       |

## Cloud-init Configuration

The script automatically configures the container with:

### User Setup
- Creates user with specified username
- Adds user to sudo/wheel groups
- Sets up passwordless sudo access
- Configures SSH key authentication
- Sets user password for console access

### System Configuration
- Updates package repositories
- Upgrades system packages
- Installs essential packages:
  - openssh-server
  - curl, wget
  - vim, htop
  - git, unzip

### Services
- Enables SSH service
- Enables systemd-resolved (if available)
- Configures hostname and hosts file

### Network
- Configures DHCP networking
- Sets up proper hostname resolution

## Container Types

### Unprivileged Containers (Default)
- **Security**: Better isolation, runs as unprivileged user
- **Use Cases**: General development, testing, web services
- **Limitations**: Cannot run Docker, some system operations restricted

### Privileged Containers (--privileged flag)
- **Security**: Less isolation, runs as root
- **Use Cases**: Docker-in-container, system administration, legacy apps
- **Capabilities**: Full system access, can run Docker and systemd

## SSH Access

After container creation, you can access the container via:

### SSH (Recommended)
```bash
# Get container IP address
incus list CONTAINER_NAME

# Connect via SSH
ssh username@CONTAINER_IP
```

### Incus Commands
```bash
# Direct shell access
incus exec CONTAINER_NAME -- /bin/bash

# Execute commands
incus exec CONTAINER_NAME -- command
```

## Prerequisites

- Incus installed and configured
- User added to `incus` and `incus-admin` groups
- Incus daemon running
- SSH key pair (auto-generated if missing)

## Integration with Management Scripts

The created containers can be managed using the `ict` script:

```bash
# List containers
ict list

# Check container status
ict status CONTAINER_NAME

# Start/stop container
ict start CONTAINER_NAME
ict stop CONTAINER_NAME

# Access container shell
ict shell CONTAINER_NAME

# Execute commands
ict exec CONTAINER_NAME "command"

# Create snapshots
ict snapshot CONTAINER_NAME backup

# Delete container
ict delete CONTAINER_NAME
```

## Performance Characteristics

### Container vs VM Comparison

| Aspect              | LXC Container    | Virtual Machine         |
| ------------------- | ---------------- | ----------------------- |
| **Startup Time**    | 1-3 seconds      | 30-60 seconds           |
| **Memory Overhead** | ~10-50MB         | ~500MB+                 |
| **Disk Usage**      | Shared with host | Separate disk image     |
| **Performance**     | Near-native      | Virtualization overhead |
| **Isolation**       | Process-level    | Hardware-level          |
| **Kernel**          | Shared with host | Separate kernel         |

### Resource Efficiency
- **CPU**: Direct access to host CPU, no virtualization overhead
- **Memory**: Efficient memory sharing with host
- **I/O**: Direct filesystem access, faster than VM disk images
- **Network**: Efficient bridge networking

## Troubleshooting

### Container Creation Issues
- Ensure Incus is running: `systemctl status incus`
- Check user permissions: `groups $USER` (should include incus)
- Verify image availability: `incus image list images:`

### SSH Access Issues
- Check container IP: `incus list CONTAINER_NAME`
- Verify SSH service: `incus exec CONTAINER_NAME -- systemctl status ssh`
- Check cloud-init logs: `incus exec CONTAINER_NAME -- cloud-init status`

### Privileged Container Issues
- Some operations require privileged containers
- Use `--privileged` flag for Docker or system-level operations
- Consider security implications of privileged containers

## Comparison with Other Container Creation Scripts

| Feature             | `ict-create` | `ivm-create` | `dt` (Distrobox) |
| ------------------- | ------------ | ------------ | ---------------- |
| Backend             | Incus LXC    | Incus VM     | Podman/Docker    |
| Cloud-init          | ✓            | ✓            | ✗                |
| SSH Setup           | ✓            | ✓            | ✗                |
| Multi-distro        | ✓            | ✓            | ✓                |
| Snapshots           | ✓ (via ict)  | ✓ (via ivm)  | ✗                |
| Resource Limits     | ✓            | ✓            | ✓                |
| Privileged Mode     | ✓            | N/A          | ✓                |
| Desktop Integration | ✗            | ✗            | ✓                |
| Startup Time        | Fast (1-3s)  | Medium (30s) | Fast (1-3s)      |

## Security Considerations

- **Unprivileged containers** are recommended for most use cases
- **Privileged containers** should be used only when necessary
- SSH keys are preferred over password authentication
- User has sudo access (consider restricting for production)
- Container shares host kernel (less isolation than VMs)

## Use Cases

### Development Environments
```bash
# Create development container
ict-create --distro ubuntu --name dev --vcpus 4 --ram 2048

# Install development tools
ict exec dev -- apt update && apt install -y build-essential nodejs python3
```

### Service Testing
```bash
# Create service container
ict-create --distro debian --name webserver --ram 1024

# Deploy and test services
ict exec webserver -- apt install -y nginx
```

### Docker Host
```bash
# Create privileged container for Docker
ict-create --distro ubuntu --name docker-host --privileged

# Install Docker inside container
ict exec docker-host -- curl -fsSL https://get.docker.com | sh
```

This script provides a quick and reliable way to create development and testing containers with Incus, offering the benefits of lightweight containerization with proper SSH access and cloud-init configuration.
