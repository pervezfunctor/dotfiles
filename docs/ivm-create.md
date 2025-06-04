# ivm-create - Incus Virtual Machine Creation Script

The `ivm-create` script creates Incus virtual machines with cloud-init configuration and SSH access enabled. It provides a streamlined way to create VMs with proper user setup, SSH key authentication, and essential packages pre-installed.

## Features

- **Cloud-init Integration**: Automatic VM configuration using cloud-init
- **SSH Access**: Pre-configured SSH access with public key authentication
- **User Management**: Creates user with sudo privileges and password authentication
- **Multiple Distributions**: Support for Ubuntu, Fedora, Arch, Debian, CentOS, and Alpine
- **Resource Configuration**: Customizable CPU, memory, and disk allocation
- **Automatic Setup**: Installs essential packages and enables services
- **SSH Key Management**: Auto-detects or generates SSH keys

## Usage

```bash
ivm-create --distro DISTRO [OPTIONS]
```

### Required Arguments

- `--distro DISTRO` - Distribution to install (ubuntu, fedora, arch, debian, centos, alpine)

### Optional Arguments

- `--name NAME` - VM name (default: distribution name)
- `--release RELEASE` - Distribution release (default: latest stable)
- `--username USER` - Username for VM (default: distribution default)
- `--password PASS` - User password (default: VM name)
- `--vcpus NUM` - Number of vCPUs (default: 2)
- `--ram MB` - RAM in MB (default: 2048)
- `--disk SIZE` - Disk size (default: 20GB)
- `--ssh-key PATH` - SSH public key path (default: auto-detect)
- `--bridge BRIDGE` - Network bridge (default: incusbr0)

## Examples

### Basic VM Creation
```bash
# Create Ubuntu VM with defaults
ivm-create --distro ubuntu

# Create Fedora VM with custom name
ivm-create --distro fedora --name my-fedora

# Create Debian VM with custom user
ivm-create --distro debian --username admin --password mypass
```

### Resource Customization
```bash
# Create VM with more resources
ivm-create --distro ubuntu --vcpus 4 --ram 4096 --disk 40GB

# Create minimal VM
ivm-create --distro alpine --vcpus 1 --ram 1024 --disk 10GB
```

### Advanced Configuration
```bash
# Use specific release
ivm-create --distro ubuntu --release 22.04

# Use custom SSH key
ivm-create --distro arch --ssh-key ~/.ssh/my_key.pub
```

## Supported Distributions

| Distribution | Default Release | Default User | Image Source                   |
| ------------ | --------------- | ------------ | ------------------------------ |
| Ubuntu       | 24.04           | ubuntu       | images:ubuntu/24.04/cloud      |
| Fedora       | 42              | fedora       | images:fedora/42/cloud         |
| Arch Linux   | current         | arch         | images:archlinux/current/cloud |
| Debian       | 12              | debian       | images:debian/12/cloud         |
| CentOS       | 9-Stream        | centos       | images:centos/9-Stream/cloud   |
| Alpine       | 3.19            | alpine       | images:alpine/3.19/cloud       |

## Cloud-init Configuration

The script automatically configures the VM with:

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
- Enables QEMU guest agent (if available)
- Configures hostname and hosts file

### Network
- Configures DHCP networking
- Sets up proper hostname resolution

## SSH Access

After VM creation, you can access the VM via:

### SSH (Recommended)
```bash
# Get VM IP address
incus list VM_NAME

# Connect via SSH
ssh username@VM_IP
```

### Incus Commands
```bash
# Direct console access
incus console VM_NAME

# Execute commands
incus exec VM_NAME -- command

# Interactive shell
incus exec VM_NAME -- /bin/bash
```

## Prerequisites

- Incus installed and configured
- User added to `incus` and `incus-admin` groups
- Incus daemon running
- SSH key pair (auto-generated if missing)

## Integration with Management Scripts

The created VMs can be managed using the `ivm` script:

```bash
# List VMs
ivm list

# Check VM status
ivm status VM_NAME

# Start/stop VM
ivm start VM_NAME
ivm stop VM_NAME

# Access VM console
ivm console VM_NAME

# Execute commands
ivm exec VM_NAME "command"

# Create snapshots
ivm snapshot VM_NAME backup

# Delete VM
ivm delete VM_NAME
```

## Troubleshooting

### VM Creation Issues
- Ensure Incus is running: `systemctl status incus`
- Check user permissions: `groups $USER` (should include incus)
- Verify image availability: `incus image list images:`

### SSH Access Issues
- Check VM IP: `incus list VM_NAME`
- Verify SSH service: `incus exec VM_NAME -- systemctl status ssh`
- Check cloud-init logs: `incus exec VM_NAME -- cloud-init status`

### Network Issues
- Verify bridge configuration: `incus network list`
- Check VM network config: `incus config show VM_NAME`

## Comparison with Other VM Creation Scripts

| Feature         | `ivm-create`  | `vm-create` (libvirt) | `vm-fedora`     |
| --------------- | ------------- | --------------------- | --------------- |
| Backend         | Incus         | libvirt/KVM           | libvirt/KVM     |
| Cloud-init      | ✓             | ✓                     | ✓               |
| SSH Setup       | ✓             | ✓                     | ✓               |
| Multi-distro    | ✓             | ✓                     | ✗ (Fedora only) |
| Snapshots       | ✓ (via ivm)   | ✗                     | ✗               |
| Resource Limits | ✓             | ✓                     | ✓               |
| Network Config  | Auto (DHCP)   | Configurable          | Bridge          |
| Image Source    | Remote images | Downloaded            | Downloaded      |

## Security Considerations

- SSH keys are preferred over password authentication
- User has sudo access (consider restricting for production)
- VM runs with default Incus security profile
- Network access depends on Incus bridge configuration

## Performance Notes

- VMs start faster than traditional libvirt VMs
- Resource overhead is lower than full virtualization
- Snapshots and copies are efficient with Incus
- Network performance depends on bridge configuration

This script provides a quick and reliable way to create development and testing VMs with Incus, offering the benefits of both containerization efficiency and full VM isolation.
