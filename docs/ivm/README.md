# IVM (Incus Virtual Machine) Management

The IVM toolset provides a comprehensive solution for managing Incus virtual machines with a libvirt-like interface. It consists of two main components:

- [`ivm`](../../../bin/vt/ivm) - Main VM management interface
- [`ivm-create`](../../../bin/vt/ivm-create) - VM creation utility with cloud-init support

## Overview

IVM (Incus Virtual Machine) is a bash-based toolset that simplifies the management of Incus virtual machines by providing a familiar command-line interface similar to libvirt. It supports creating, managing, and interacting with VMs across multiple Linux distributions.

## Installation

### Prerequisites

- Incus installed on your system
- Bash shell
- SSH key pair for VM access

### Installing Incus

If Incus is not already installed, you can install it using the built-in command:

```bash
ivm install
```

This will use the `ilmi` tool to install Incus and configure the necessary permissions.

## Main Tool: ivm

The `ivm` script is the primary interface for managing Incus VMs. It provides a comprehensive set of commands for VM lifecycle management.

### Basic Usage

```bash
ivm <command> [args...]
```

### Commands

#### VM Lifecycle Management

| Command                    | Description                              | Example                                      |
| -------------------------- | ---------------------------------------- | -------------------------------------------- |
| `list`                     | List all Incus VMs                       | `ivm list`                                   |
| `status <name>`            | Show VM status and info                  | `ivm status my-vm`                           |
| `create [ivm-create args]` | Create a new VM (forwards to ivm-create) | `ivm create --distro ubuntu --name myubuntu` |
| `start <name>`             | Start a VM                               | `ivm start my-vm`                            |
| `stop <name>`              | Stop a VM                                | `ivm stop my-vm`                             |
| `restart <name>`           | Restart a VM                             | `ivm restart my-vm`                          |
| `delete <name>`            | Delete a VM completely                   | `ivm delete my-vm`                           |

#### VM Interaction

| Command                 | Description                 | Example                 |
| ----------------------- | --------------------------- | ----------------------- |
| `console <name>`        | Connect to VM console       | `ivm console my-vm`     |
| `exec <name> <cmd>`     | Execute command in VM       | `ivm exec my-vm ls -la` |
| `shell <name>`          | Get interactive shell in VM | `ivm shell my-vm`       |
| `ip <name>`             | Get VM IP address           | `ivm ip my-vm`          |
| `ssh <name> <username>` | Connect to VM via SSH       | `ivm ssh my-vm admin`   |

#### VM Information

| Command              | Description                                     | Example                     |
| -------------------- | ----------------------------------------------- | --------------------------- |
| `info <name>`        | Show detailed VM information                    | `ivm info my-vm`            |
| `config <name>`      | Show VM configuration                           | `ivm config my-vm`          |
| `logs <name> [type]` | Show VM logs (instance, console, or cloud-init) | `ivm logs my-vm cloud-init` |

#### Snapshot Management

| Command                  | Description              | Example                         |
| ------------------------ | ------------------------ | ------------------------------- |
| `snapshot <name> [snap]` | Create VM snapshot       | `ivm snapshot my-vm backup-001` |
| `restore <name> <snap>`  | Restore VM from snapshot | `ivm restore my-vm backup-001`  |
| `copy <src> <dest>`      | Copy VM                  | `ivm copy my-vm my-vm-copy`     |

#### Device Management

##### USB Devices

| Command                             | Description                            | Example                           |
| ----------------------------------- | -------------------------------------- | --------------------------------- |
| `usb-list`                          | List all available USB devices on host | `ivm usb-list`                    |
| `usb-attached <name>`               | List USB devices attached to VM        | `ivm usb-attached my-vm`          |
| `usb-attach <name> <device> [name]` | Attach USB device to VM                | `ivm usb-attach my-vm 1234:5678`  |
| `usb-detach <name> <device>`        | Detach USB device from VM              | `ivm usb-detach my-vm usb-device` |

##### Disk Devices

| Command                              | Description                              | Example                             |
| ------------------------------------ | ---------------------------------------- | ----------------------------------- |
| `disk-list`                          | List all available block devices on host | `ivm disk-list`                     |
| `disk-attached <name>`               | List disk devices attached to VM         | `ivm disk-attached my-vm`           |
| `disk-attach <name> <device> [name]` | Attach raw disk device to VM             | `ivm disk-attach my-vm /dev/sdb`    |
| `disk-detach <name> <device>`        | Detach disk device from VM               | `ivm disk-detach my-vm disk-device` |

#### Utility Commands

| Command   | Description              | Example       |
| --------- | ------------------------ | ------------- |
| `cleanup` | Remove stopped VMs       | `ivm cleanup` |
| `install` | Install Incus using ilmi | `ivm install` |

### Examples

```bash
# Create and manage an Ubuntu VM
ivm create --distro ubuntu --name myubuntu --vcpus 4 --memory 4096
ivm start myubuntu
ivm status myubuntu
ivm ssh myubuntu admin

# Create a Fedora VM with custom configuration
ivm create --distro fedora --name myfedora --dotfiles shell-slim docker

# Create an Alpine VM with Nix
ivm create --distro alpine --release 3.19 --nix

# USB device management
ivm usb-list
ivm usb-attach my-vm 1234:5678
ivm usb-attached my-vm
ivm usb-detach my-vm usb-device

# Disk management
ivm disk-list
ivm disk-attach my-vm /dev/sdb data-disk
ivm disk-attached my-vm
ivm disk-detach my-vm data-disk
```

## Creation Tool: ivm-create

The `ivm-create` script is used to create new Incus VMs with cloud-init configuration and SSH access. It's automatically called by `ivm create` but can also be used directly.

### Basic Usage

```bash
ivm-create --distro DISTRO [OPTIONS]
```

### Required Parameters

| Parameter         | Description                                                             |
| ----------------- | ----------------------------------------------------------------------- |
| `--distro DISTRO` | Distribution (ubuntu, fedora, arch, debian, centos, tumbleweed, alpine) |

### Optional Parameters

| Parameter           | Default        | Description          |
| ------------------- | -------------- | -------------------- |
| `--name NAME`       | distro name    | VM name              |
| `--release RELEASE` | latest         | Distribution release |
| `--username USER`   | distro default | Username for VM      |
| `--password PASS`   | vm name        | User password        |
| `--vcpus NUM`       | 4              | Number of vCPUs      |
| `--memory MB`       | 4096           | RAM in MB            |
| `--disk-size SIZE`  | 20GB           | Disk size            |
| `--ssh-key PATH`    | auto-detect    | SSH public key path  |
| `--bridge BRIDGE`   | incusbr0       | Network bridge       |

### Supported Distributions

| Distribution | Default Release | Image                            |
| ------------ | --------------- | -------------------------------- |
| ubuntu       | plucky/25.04    | images:ubuntu/plucky/cloud       |
| fedora       | 42              | images:fedora/42/cloud           |
| arch         | current         | images:archlinux/current/cloud   |
| debian       | 13/trixie       | images:debian/13/cloud           |
| centos       | 9-Stream        | images:centos/9-Stream/cloud     |
| tumbleweed   | current         | images:opensuse/tumbleweed/cloud |
| alpine       | 3.22            | images:alpine/3.22/cloud         |

### Examples

```bash
# Basic Ubuntu VM
ivm-create --distro ubuntu

# Custom Fedora VM
ivm-create --distro fedora --name my-fedora --vcpus 4 --memory 4096

# Debian VM with custom user
ivm-create --distro debian --username admin --password mypass

# Arch Linux with larger disk
ivm-create --distro arch --release current --disk-size 40GB

# openSUSE Tumbleweed with custom resources
ivm-create --distro tumbleweed --name opensuse-vm --vcpus 2 --memory 4096
```

## Features

### Cloud-Init Integration

Both tools automatically configure cloud-init for:
- User creation with sudo access
- SSH key authentication
- Package installation and updates
- Service configuration
- Network setup

### Security Features

- Automatic SSH key setup
- Password-based authentication available
- Secure user configuration with sudo access
- Firewall and security hardening through cloud-init

### Device Passthrough

- USB device attachment/detachment
- Raw disk device passthrough
- Hot-plug support for running VMs
- Device listing and management

### Snapshot Management

- Create VM snapshots
- Restore from snapshots
- Copy VMs with full state preservation

## Troubleshooting

### Common Issues

1. **Permission denied errors**
   - Ensure user is in the `incus-admin` group
   - Try logging out and back in after group changes

2. **VM creation fails**
   - Check network connectivity
   - Verify image availability with `incus image list`
   - Ensure sufficient disk space

3. **SSH connection issues**
   - Verify SSH key is properly configured
   - Check VM network configuration
   - Ensure SSH service is running in the VM

4. **USB device issues**
   - Ensure VM is running before attaching devices
   - Check device permissions on host
   - Verify device is not in use by host system

### Getting Help

```bash
# Get help for ivm
ivm --help

# Get help for ivm-create
ivm-create --help

# Check VM status and logs
ivm status <vm-name>
ivm logs <vm-name> cloud-init
```

## Integration with Other Tools

IVM integrates seamlessly with:
- **ilmi** - For Incus installation
- **incus** - Direct Incus CLI access
- **ssh** - Standard SSH client for VM access
- **cloud-init** - VM initialization and configuration

## Best Practices

1. **Naming Conventions**: Use descriptive VM names that indicate purpose and OS
2. **Resource Planning**: Allocate appropriate vCPUs and memory based on workload
3. **Regular Snapshots**: Create snapshots before major changes
4. **Security**: Use SSH keys instead of passwords when possible
5. **Monitoring**: Regularly check VM status and logs
6. **Cleanup**: Remove unused VMs to free up resources

## Contributing

The IVM toolset is part of the larger dotfiles configuration. Contributions and improvements are welcome through the standard project contribution process.
