# VME (Virtual Machine Environment) Tools

The VME tools provide a simplified interface for managing virtual machines using libvirt/KVM. This documentation covers the main scripts and utilities:

## Core Tools

| Script | Bash | Nushell |
|--------|------|---------|
| VM management | [`bin/vt/vme`](../../../bin/vt/vme) | [`nu/vme.nu`](../../../nu/vme.nu) |
| VM creation | [`bin/vt/vme-create`](../../../bin/vt/vme-create) | — |

## Additional Utilities

| Script | Bash | Nushell |
|--------|------|---------|
| Batch operations | [`bin/vt/vme-all`](../../../bin/vt/vme-all) | [`nu/vme-all.nu`](../../../nu/vme-all.nu) |
| Tmux sessions | [`bin/vt/vme-tmux`](../../../bin/vt/vme-tmux) | [`nu/vme-tmux.nu`](../../../nu/vme-tmux.nu) |

See the following documentation for detailed information:
- [vme-all](vme-all.md) - Batch operations for multiple VMs
- [vme-tmux](vme-tmux.md) - Tmux session management

## Overview

VME is designed to make VM management more user-friendly while leveraging the power of libvirt and KVM. These tools focus on user-mode VMs that are easier to manage than full libvirt VMs.

## Prerequisites

Before using VME tools, ensure you have:

1. **libvirt and KVM installed**:
   ```bash
   # On Debian/Ubuntu
   sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils

   # On Arch Linux
   sudo pacman -S qemu libvirt edk2-ovmf
   ```

2. **User in libvirt group**:
   ```bash
   sudo usermod -aG libvirt $USER
   # Log out and log back in for changes to take effect
   ```

3. **Required tools**:
   - `virsh` (libvirt client)
   - `virt-install` (for VM creation)
   - `qemu-img` (for disk management)
   - `trash` (for safe deletion)
   - `whiptail` (for interactive mode, optional)

## vme - VM Management Utility

The `vme` script provides a comprehensive interface for managing existing VMs.

### Basic Usage

```bash
vme <command> [vm-name]
```

### Commands

#### VM Lifecycle Management
- `list` / `ls` - List all VMs
- `create <args>` - Create a new VM (same arguments as vme-create)
- `create-all` - Interactively select distros and create VMs
- `all <op>` - Perform operation on all standard VMs
- `start [vm-name...]` - Start VM(s); prompts with fzf if none given
- `shutdown [vm-name...]` - Gracefully stop VM(s)
- `restart [vm-name...]` - Restart VM(s)
- `kill [vm-name...]` - Force stop VM(s)
- `delete [vm-name...]` - Delete VM(s) completely

#### VM Information
- `info <vm-name>` - Show VM status and information
- `ip <vm-name>` - Show VM IP address
- `is-running <vm-name>` - Check if VM is running (prints true/false)
- `disk <vm-name>` - Show VM disk block devices
- `logs <vm-name>` - Show cloud-init logs

#### VM Access
- `console <vm-name>` - Connect to VM serial console (exit with `Ctrl+]`)
- `ssh <vm-name> [user]` - SSH into VM (defaults to `$USER`)
- `exec <vm-name> <cmd...>` - Run a command in VM via SSH

#### Configuration
- `autostart <vm-name>` - Set VM to start on boot

#### Advanced
- `cmd <virsh-args>` - Run virsh command with qemu:///system connection
- `net <command>` - Manage libvirt virtual networks
- `tmux` - Interactively select VMs and open a tmux grid session
- `start-libvirt` - Start the libvirtd service

### Examples

```bash
# List all VMs
vme list

# Show IP address of a VM
vme ip debian

# Check if VM is running
vme is-running debian

# Start one or more VMs
vme start debian
vme start debian fedora

# Start — prompt with fzf if no name given
vme start

# SSH into a VM (defaults to $USER)
vme ssh debian

# Run a command in a VM
vme exec debian 'systemctl status sshd'

# Delete a VM completely
vme delete old-vm

# Manage virtual networks
vme net list
vme net info default
```

### Network Management

The `net` subcommand provides access to libvirt network management:

```bash
vme net list                    # List all virtual networks
vme net info default            # Show details of 'default' network
vme net start default           # Start 'default' network
vme net auto-start default      # Set network to start on boot
vme net stop default            # Stop 'default' network
vme net delete old-network      # Delete 'old-network'
```

## vme-create - VM Creation Utility

The `vme-create` script simplifies the process of creating new VMs with cloud-init support.

### Usage

```bash
# Interactive mode (recommended for beginners)
vme-create

# Command-line mode
vme-create [options]
```

### Options

- `--username USERNAME` - Set the username for the VM (default: current user)
- `--password PASSWORD` - Set the password for the VM
- `--vcpus VCPUS` - Set the number of vCPUs (default: 4)
- `--memory MEMORY` - Set the amount of memory in MB (default: 8192)
- `--distro DISTRO` - Set the distribution (arch, ubuntu, debian, fedora, tumbleweed)
- `--name VM_NAME` - Set the name of the VM
- `--release RELEASE` - Set the release version
- `--bridge BRIDGE` - Set the network bridge (default: 'default')
- `--disk-size SIZE` - Set the disk size (default: '30G')
- `--help` - Show help message

### Important Options Details

#### Basic Configuration Options
- `--username USERNAME` - Set the username for the VM (default: current user)
  - If not specified, defaults to the current system user
  - Can be any valid username (no special restrictions)

- `--password PASSWORD` - Set the password for the VM
  - If not specified, automatically generates a secure password
  - Password generation priority: `pass` → `pwgen` → `openssl` → username
  - Generated password is displayed at completion in a colored box

- `--name VM_NAME` - Set the name of the VM
  - Distribution-specific defaults if not specified
  - Must be unique (no existing VMs with same name)
  - Used as hostname and for identification

- `--distro DISTRO` - Set the distribution (required for command-line mode)
  - Supported: arch, ubuntu, debian, fedora, tumbleweed
  - Determines default settings, packages, and user groups

#### Resource Allocation Options
- `--vcpus VCPUS` - Set the number of virtual CPUs (default: 4)
  - Recommended: 2-8 vCPUs for most workloads
  - More vCPUs = more host CPU usage

- `--memory MEMORY` - Set the amount of memory in MB (default: 8192)
  - Recommended: 4096MB minimum for modern Linux desktops
  - 8192MB (8GB) good for development workloads
  - 16384MB+ for heavy development/containers

- `--disk-size SIZE` - Set the disk size (default: '30G')
  - Format: number followed by G or M (e.g., 30G, 512M)
  - Recommended: 30G minimum, 50G+ for development
  - Disk is thin-provisioned (grows as needed)

#### Network and Release Options
- `--bridge BRIDGE` - Set the network bridge (default: 'default')
  - 'default' uses libvirt's default network
  - Can specify custom bridge interfaces
  - Bridge must exist and be active

- `--release RELEASE` - Set the release version
  - Distribution-specific defaults if not specified
  - Arch: 'latest' (always rolling)
  - Ubuntu: 'plucky' (25.10)
  - Debian: 'trixie' (13)
  - Fedora: 42
  - Tumbleweed: 'latest' (rolling)

### Distribution-Specific Defaults

| Distribution        | Default VM Name | Default Release | Default Username | sudo group |
| ------------------- | --------------- | --------------- | ---------------- | ---------- |
| Arch Linux          | arch-vme        | latest          | arch             | wheel      |
| Ubuntu              | ubuntu-vme      | questing (25.10)| ubuntu           | sudo       |
| Debian              | debian-vme      | trixie (13)     | debian           | sudo       |
| Fedora              | fedora-vme      | 43              | fedora           | wheel      |
| openSUSE Tumbleweed | tw-vme          | latest          | opensuse         | wheel      |
| CentOS Stream       | centos-vme      | 9               | centos           | wheel      |
| Rocky Linux         | rocky-vme       | 9               | rocky            | wheel      |
| Alpine Linux        | alpine-vme      | 3.22            | alpine           | wheel      |

### Password Generation Details

If no password is specified, the system automatically generates one using this priority:
1. **`pass` command** (password store) - generates 12-character secure password
2. **`pwgen` command** - generates 12-character pronounceable password
3. **`openssl rand -base64 12`** - generates random 12-character password
4. **Fallback to username** if all password generation tools fail

The generated password is displayed at the end of the VM creation process in a colored completion box.

### Interactive Mode Features

When run without arguments, `vme-create` provides an interactive menu system using `whiptail`:

1. **Distribution Selection** - Choose from 5 supported distributions with descriptions
2. **VM Configuration** - Set name, username, password with validation
3. **Resource Allocation** - Configure vCPUs, memory, disk size with input validation
4. **Network Setup** - Select bridge interface with availability checking
5. **Summary Review** - Confirm all settings before creation with option to go back

### Cloud-Init Configuration Details

The script automatically configures each VM with:
- **Essential packages**: qemu-guest-agent, curl, openssh-server (or openssh)
- **User management**: Configured user with sudo access and SSH keys
- **Service enablement**: SSH and QEMU guest agent services enabled and started
- **Security settings**: SSH password authentication disabled, root login disabled
- **Network configuration**: DHCP client enabled for automatic IP assignment

### Examples

```bash
# Interactive mode - guided setup with validation
vme-create

# Create Arch Linux VM with all defaults
vme-create --distro arch

# Create Ubuntu VM with custom resources
vme-create --distro ubuntu --name ubuntu-dev --vcpus 8 --memory 16384 --disk-size 50G

# Create Debian VM with custom credentials
vme-create --distro debian --username myuser --password mypass --name debian-test

# Create Fedora VM with specific release
vme-create --distro fedora --release 41 --name fedora-41

# Create openSUSE Tumbleweed VM with minimal resources
vme-create --distro tumbleweed --name tw-test --vcpus 2 --memory 4096 --disk-size 20G

# Create VM with custom bridge
vme-create --distro ubuntu --name ubuntu-bridge --bridge virbr1
```

### VM Creation Process

1. **Prerequisites Check**:
   - Verifies libvirt group membership
   - Checks for existing VM names
   - Validates disk file availability

2. **Distribution Setup**:
   - Configures distribution-specific settings
   - Sets appropriate OS variant for virt-install
   - Determines user groups and packages

3. **Storage Preparation**:
   - Creates directories with proper permissions
   - Sets up base image storage location
   - Configures user:kvm ownership

4. **Base Image Download**:
   - Downloads cloud image if not already present
   - Uses distribution-specific URLs
   - Shows progress during download

5. **Cloud-Init Generation**:
   - Creates user-data and meta-data configuration
   - Configures SSH keys and user access
   - Sets up packages and services

6. **Disk Creation**:
   - Creates qcow2 disk based on base image
   - Resizes to specified disk size
   - Uses copy-on-write for efficiency

7. **VM Launch**:
   - Uses virt-install to create and start the VM
   - Configures network and graphics settings
   - Disables auto-console for background operation

8. **Completion Info**:
   - Displays access credentials in colored box
   - Shows next steps for SSH access
   - Provides troubleshooting guidance

### Storage Structure

VMs are created in `/var/lib/libvirt/images/` with this structure:
```
/var/lib/libvirt/images/
├── base-images/                    # Downloaded cloud images (shared)
│   └── Arch-Linux-x86_64-cloudimg.qcow2
└── arch-vme/                      # VM-specific directory
    ├── arch-vme.qcow2             # VM disk image
    └── cloud-init/                 # Temporary cloud-init files (cleaned up)
```

### Supported Distributions

1. **Arch Linux** (`--distro arch`)
   - Default: arch-vme
   - Release: latest
   - Base image: Arch-Linux-x86_64-cloudimg.qcow2

2. **Ubuntu** (`--distro ubuntu`)
   - Default: ubuntu-vme
   - Release: questing (25.10)
   - Base image: questing-server-cloudimg-amd64.img

3. **Debian** (`--distro debian`)
   - Default: debian-vme
   - Release: trixie (Debian 13)
   - Base image: debian-13-generic-amd64.qcow2

4. **Fedora** (`--distro fedora`)
   - Default: fedora-vme
   - Release: 43
   - Base image: Fedora-Cloud-Base-Generic-43-1.6.x86_64.qcow2

5. **openSUSE Tumbleweed** (`--distro tumbleweed` or `tw`)
   - Default: tw-vme
   - Release: latest
   - Base image: openSUSE-Tumbleweed-Minimal-VM.x86_64-Cloud.qcow2

6. **CentOS Stream** (`--distro centos`)
   - Default: centos-vme
   - Release: 9-Stream
   - Base image: CentOS-Stream-GenericCloud-9-latest.x86_64.qcow2

7. **Rocky Linux** (`--distro rocky`)
   - Default: rocky-vme
   - Release: 9
   - Base image: Rocky-9-GenericCloud.latest.x86_64.qcow2

8. **Alpine Linux** (`--distro alpine`)
   - Default: alpine-vme
   - Release: 3.22.2
   - Base image: generic_alpine-3.22.2-x86_64-uefi-cloudinit-r0.qcow2

### Examples

```bash
# Create an Arch Linux VM with default settings
vme-create --distro arch

# Create an Ubuntu VM with custom resources
vme-create --distro ubuntu --name ubuntu-dev --vcpus 8 --memory 16384 --disk-size 50G

# Create a Debian VM with custom credentials
vme-create --distro debian --username myuser --password mypass

# Interactive mode
vme-create
```

### VM Creation Process

1. **Prerequisites Check**: Verifies user permissions and checks for existing VMs
2. **Base Image Download**: Downloads the appropriate cloud image if not already present
3. **Cloud-Init Configuration**: Generates user-data and meta-data for initial setup
4. **Disk Creation**: Creates a qcow2 disk based on the base image
5. **VM Installation**: Uses virt-install to create the VM with cloud-init
6. **Completion Info**: Displays connection information and next steps

### Post-Creation Access

After VM creation, you can:

1. **Check VM status**:
   ```bash
   virsh domstate <vm-name>
   ```

2. **Get IP address**:
   ```bash
   virsh domifaddr <vm-name> --source agent
   ```

3. **SSH access**:
   ```bash
   ssh <username>@<ip-address>
   ```

4. **Console access**:
   ```bash
   virsh console <vm-name>
   # Exit with Ctrl+]
   ```

## Storage Location

VMs are stored in `/var/lib/libvirt/images/` with the following structure:
- Base images: `/var/lib/libvirt/images/base-images/`
- Individual VMs: `/var/lib/libvirt/images/<vm-name>/`

## User Detection

The `vme ssh` command defaults to `$USER` if no username is given. The nushell `default-username` helper in `share/vt-utils.nu` can also map a distro name to its conventional username:
- `ubuntu*` → `ubuntu`
- `fedora*` → `fedora`
- `centos*` → `centos`
- `debian*` → `debian`
- `arch*` → `arch`
- `alpine*` → `alpine`
- `nix*` → `nixos`
- `rocky*` → `rocky`
- `tumbleweed*` / `tw*` → `opensuse`
- All others → `$USER`

## Troubleshooting

### Common Issues

1. **Permission denied**:
   - Ensure your user is in the `libvirt` group
   - Log out and log back in after adding to the group

2. **VM not getting IP**:
   - Ensure the VM is running
   - Check if QEMU guest agent is installed
   - Verify the virtual network is active

3. **SSH connection fails**:
   - Check if the VM has an IP address
   - Verify the SSH service is running
   - Check firewall settings

4. **Console access issues**:
   - Use Ctrl+] to exit the console
   - Try `virsh console <vm-name> --force` if needed

### Debug Commands

```bash
# Check VM status
vme info <vm-name>

# View cloud-init logs
vme logs <vm-name>

# Check network configuration
vme net info default

# Direct virsh access
vme cmd list --all
```

## Integration with Other Tools

VME integrates with several other tools in this environment:

- **`share/vm-utils.nu`** / **`bin/vt/vm-utils`**: Shared VM management functions
- **`share/vt-utils.nu`** / **`bin/vt/vt-utils`**: Generic VT helpers (`wait-for-ip`, `handle-multiple-arguments`, etc.)
- **`share/tmux-utils.nu`** / **`bin/vt/tmux-utils`**: Tmux session helpers
- **fzf**: Interactive VM/distro selection when no name is given
- **pass** / **pwgen** / **openssl**: Password generation fallback chain

## Best Practices

1. **Naming Convention**: Use descriptive VM names that include the distribution
2. **Resource Allocation**: Allocate appropriate resources based on workload
3. **Regular Maintenance**: Periodically clean up unused VMs and base images
4. **Security**: Use SSH keys instead of passwords when possible
5. **Backups**: Regularly back up important VM data

## Environment Variables

- `DOT_DIR`: Set to `$HOME/.ilm` by default, contains utility scripts
- `VME_SSH_CONNECT_TIMEOUT`: SSH connection timeout in seconds (default: 15)

## Complete Workflow: From Creation to SSH Access

Here's a step-by-step workflow for creating a VM and accessing it via SSH:

### Step 1: Create a VM

```bash
# Create an Ubuntu VM with default settings
vme-create --distro ubuntu --name ubuntu-dev

# Or use interactive mode
vme-create
```

### Step 2: Wait for VM to Boot and Initialize

```bash
# Check if VM is running
vme info ubuntu-dev

# Wait a minute for cloud-init to complete
vme logs ubuntu-dev  # Check cloud-init progress
```

### Step 3: Get VM IP Address

```bash
# Get the IP address
vme ip ubuntu-dev

# Or use virsh directly
virsh domifaddr ubuntu-dev --source agent
```

### Step 4: SSH Access

```bash
# Method 1: Using vme ssh command (recommended)
vme ssh ubuntu-dev

# Method 2: Using IP address directly
ssh ubuntu@<ip-address-from-step-3>

# Method 3: Using VM name with libvirt-nss (Fedora only)
ssh ubuntu@ubuntu-dev
```

### Step 5: If SSH Doesn't Work

If SSH access fails, use the console to troubleshoot:

```bash
# Access the VM console
vme console ubuntu-dev

# Or using virsh directly
virsh console ubuntu-dev
# Exit with Ctrl+]

# In the console, check:
# - SSH service status: systemctl status sshd
# - Network status: ip addr show
# - Cloud-init logs: cat /var/log/cloud-init.log
```

## Default Credentials by Distribution

Each distribution has default username patterns and password generation:

| Distribution | Default Username           | Default Password            |
| ------------ | -------------------------- | --------------------------- |
| Arch Linux   | `arch` or current user     | Auto-generated or specified |
| Ubuntu       | `ubuntu` or current user   | Auto-generated or specified |
| Debian       | `debian` or current user   | Auto-generated or specified |
| Fedora       | `fedora` or current user   | Auto-generated or specified |
| openSUSE     | `opensuse` or current user | Auto-generated or specified |

**Note**: If no password is specified during creation, the system will:
1. Try to generate one using `pass` (password store)
2. Fall back to `pwgen` if available
3. Use `openssl` as last resort
4. Default to the username if all else fails

The generated password is displayed at the end of the VM creation process.

## SSH Access Methods

### Method 1: Using vme ssh (Recommended)

```bash
# Auto-detects user and IP
vme ssh <vm-name>

# Specify user explicitly
vme ssh <vm-name> <username>
```

### Method 2: Using IP Address

```bash
# Get IP first
vme ip <vm-name>

# Then SSH
ssh <username>@<ip-address>
```

### Method 3: Using VM Name (libvirt-nss)

On systems with libvirt-nss configured (Fedora), you can SSH directly using the VM name:

```bash
# Install libvirt-nss if not present
sudo dnf install libvirt-nss

# Configure /etc/nsswitch.conf to include libvirt
# Add "libvirt" to the hosts line: hosts: files libvirt dns

# SSH using VM name
ssh <username>@<vm-name>
```

Example:
```bash
ssh ubuntu@ubuntu-dev
ssh debian@debian-vme
ssh arch@arch-vme
```

## Troubleshooting SSH Connection Issues

### Common Problems and Solutions

1. **SSH connection refused**:
   ```bash
   # Check if VM is running
   vme info <vm-name>

   # Access console to check SSH service
   vme console <vm-name>
   # Inside VM: systemctl status sshd
   # Inside VM: sudo systemctl enable --now sshd
   ```

2. **SSH connection timeout**:
   ```bash
   # Check if VM has IP address
   vme ip <vm-name>

   # If no IP, check network configuration
   vme net info default
   ```

3. **Authentication failed**:
   ```bash
   # Verify credentials
   vme ssh <vm-name>  # Shows username being used

   # Access console to reset password if needed
   vme console <vm-name>
   # Inside VM: sudo passwd <username>
   ```

4. **Host key verification issues**:
   ```bash
   # Remove old host key
   ssh-keygen -R <vm-ip-or-name>

   # Or disable verification (not recommended for production)
   ssh -o StrictHostKeyChecking=no <username>@<host>
   ```

### Console Access When SSH Fails

The console is your fallback when SSH doesn't work:

```bash
# Access console
vme console <vm-name>

# Common troubleshooting commands inside the console:
# - Check network: ip addr show
# - Check SSH: systemctl status sshd
# - Check cloud-init: cat /var/log/cloud-init.log
# - Restart services: sudo systemctl restart sshd
# - Check firewall: sudo ufw status
```

Remember to exit the console with `Ctrl+]`.
