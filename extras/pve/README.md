# VM Template Creator for Proxmox VE

This repository contains scripts that automate the creation of VM templates in Proxmox VE, with enhanced security and robustness features.

## Scripts

### debian-vm-template
Creates Debian VM templates in Proxmox VE.

### vm-template
Creates VM templates for multiple distributions (Debian, Fedora, Ubuntu, Alpine, CentOS, openSUSE Tumbleweed, Arch Linux) in Proxmox VE.

### vm-templates-create-all
Creates VM templates for all supported distributions in a single run.

### vm-create-all
Creates VMs from all available VM templates in a single run.

## Features

- **Secure credential handling**: Uses environment variables instead of hardcoded passwords
- **Checksum verification**: Optional SHA256 verification for downloaded images
- **Retry logic**: Automatic retry for network operations
- **Progress indicators**: Visual feedback during downloads
- **Comprehensive validation**: Validates all parameters before execution
- **Error handling**: Robust cleanup on failure
- **Configuration file support**: External configuration with validation

## Security Improvements

The script has been enhanced with the following security features:

1. **Environment variable support**: Credentials are now sourced from environment variables
   - `CLOUD_INIT_USER`: Username for cloud-init (default: debian)
   - `CLOUD_INIT_PASSWORD`: Password for cloud-init (default: empty)

2. **No hardcoded passwords**: The script no longer contains default passwords

3. **Optional password**: Password is optional - you can use SSH keys instead

## Usage

### Basic Usage

```bash
# Set credentials as environment variables
export CLOUD_INIT_USER="myuser"
export CLOUD_INIT_PASSWORD="mypassword"

# Run the script
./debian-vm-template -i 9001 -n my-template -s local-lvm -U "https://cdimage.debian.org/cdimage/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
```

### With Checksum Verification

```bash
./debian-vm-template -i 9001 -n my-template -s local-lvm \
  -U "https://cdimage.debian.org/cdimage/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2" \
  -C "sha256:abcdef1234567890..."
```

### Using Configuration File

1. Copy `options.example` to `options`:
```bash
cp options.example options
```

2. Edit the `options` file with your desired settings

3. Run the script:
```bash
./debian-vm-template
```

## Command Line Options

- `-s, --storage STORAGE`: Proxmox storage target (e.g., local-lvm)
- `-i, --vm-id VM_ID`: Unique ID for the new VM
- `-n, --vm-name VM_NAME`: Name for the VM
- `-d, --disk-size DISK_SIZE`: Size of the VM disk (default: 32G)
- `-m, --memory MEMORY`: VM memory in MB (default: 8192)
- `-c, --cores CORES`: Number of CPU cores (default: 4)
- `-u, --username USERNAME`: Username for cloud-init (default: debian)
- `-p, --password PASSWORD`: Password for cloud-init (default: empty)
- `-U, --url DEBIAN_IMAGE_URL`: URL of the Debian cloud image
- `-C, --checksum CHECKSUM`: Expected SHA256 checksum of the image
- `-h, --help`: Display help message
- `--debug`: Enable debug logging

## Environment Variables

- `CLOUD_INIT_USER`: Default username for cloud-init
- `CLOUD_INIT_PASSWORD`: Default password for cloud-init
- `DOWNLOAD_RETRY_ATTEMPTS`: Number of download retry attempts (default: 3)
- `DEBUG`: Set to 1 to enable debug logging
- `EXPECTED_CHECKSUM`: Default SHA256 checksum for image verification

## Configuration File

The script supports an external configuration file named `options` in the same directory. This file should contain bash variable assignments. See `options.example` for a template.

The configuration file supports:
- Variable expansion (e.g., `USERNAME="${CLOUD_INIT_USER:-debian}"`)
- Comments (lines starting with #)
- Environment variable substitution

## Security Best Practices

1. **Use environment variables**: Never pass passwords on the command line
2. **Verify checksums**: Always provide checksums for downloaded images
3. **Use SSH keys**: Consider using SSH keys instead of passwords when possible
4. **Limit permissions**: Run the script with minimal required permissions
5. **Clean up**: The script automatically cleans up temporary files and failed VMs

## Example Workflow

```bash
# 1. Set environment variables
export CLOUD_INIT_USER="admin"
export CLOUD_INIT_PASSWORD="secure-password"

# 2. Get the checksum of the image (optional but recommended)
wget -q -O - "https://cdimage.debian.org/cdimage/cloud/trixie/latest/SHA256SUMS" | grep "debian-13-genericcloud-amd64.qcow2"

# 3. Run the script with checksum
./debian-vm-template \
  -i 9001 \
  -n "debian-13-template" \
  -s "local-lvm" \
  -U "https://cdimage.debian.org/cdimage/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2" \
  -C "your-sha256-checksum-here"

# 4. Verify the template was created
qm list | grep 9001
```

## Troubleshooting

### Download Issues
- Check network connectivity
- Verify the URL is accessible
- Consider using a different mirror if the default is slow

### Permission Issues
- Ensure you have sufficient permissions in Proxmox
- Check that the target storage exists and is accessible

### VM Creation Issues
- Verify the VM ID is not already in use
- Check that the storage has sufficient space
- Ensure all required Proxmox tools are installed

## Requirements

- Proxmox VE
- bash
- wget
- Standard Unix tools (sha256sum, qm, pvesm)

## vm-template Script Features

The `vm-template` script supports multiple Linux distributions and provides the same enhanced features as `debian-vm-template`:

### Supported Distributions
- **Debian** (ID: 201) - Latest Debian cloud image
- **Fedora** (ID: 202) - Latest Fedora Cloud image
- **Ubuntu** (ID: 203) - Latest Ubuntu cloud image with UEFI support
- **Alpine** (ID: 204) - Latest Alpine cloud image
- **CentOS** (ID: 205) - Latest CentOS Stream cloud image
- **openSUSE Tumbleweed** (ID: 206) - Latest openSUSE Tumbleweed cloud image with UEFI support
- **Arch Linux** (ID: 207) - Latest Arch Linux cloud image

### Usage Examples

```bash
# Create a Debian template
./vm-template -D debian

# Create an Ubuntu template with SSH key
./vm-template -D ubuntu -k ~/.ssh/id_rsa.pub -m 4096 -c 2

# Create a Fedora template with custom settings
./vm-template -D fedora -i 1001 -n my-fedora-template -C "sha256:abcdef..."

# Create an openSUSE Tumbleweed template
./vm-template -D tumbleweed -k ~/.ssh/id_rsa.pub -m 4096

# Create an Arch Linux template
./vm-template -D arch -k ~/.ssh/id_rsa.pub -m 4096

# Create with environment variables
export CLOUD_INIT_USER="admin"
export CLOUD_INIT_PASSWORD="secure-password"
./vm-template -D alpine
```

### Configuration File Support

Create an `options` file in the same directory as the script:

```bash
# Example options file for vm-template
PROXMOX_STORAGE="local-lvm"
DISK_SIZE="64G"
MEMORY="4096"
CORES="8"
USERNAME="myuser"
PASSWORD="${CLOUD_INIT_PASSWORD:-}"
SSH_KEY="${SSH_KEY_PATH:-}"
```

See `vm-options.example` for a complete template.

## vm-templates-create-all Script Features

The `vm-templates-create-all` script automates the creation of VM templates for all supported distributions in a single run.

### Features

- **Batch creation**: Creates templates for all supported distributions at once
- **Selective creation**: Option to retry only failed distributions
- **Dry-run mode**: Preview what would be done without executing
- **Progress tracking**: Shows which distributions are being processed
- **Error handling**: Continues with other distributions if one fails
- **Summary reporting**: Provides detailed success/failure summary

### Usage Examples

```bash
# Create all templates with default settings
./vm-templates-create-all

# Create all templates with custom storage, memory, and cores
./vm-templates-create-all -s local-zfs -m 4096 -c 2

# Create all templates using SSH key authentication
./vm-templates-create-all -k ~/.ssh/id_rsa.pub

# Only retry distributions that failed previously
./vm-templates-create-all -f

# Preview what would be done without executing
./vm-templates-create-all --dry-run

# List all supported distributions and their VM IDs
./vm-templates-create-all --list
```

### Command Line Options

- `-s, --storage STORAGE`: Proxmox storage target (default: local-lvm)
- `-d, --disk-size DISK_SIZE`: Size of VM disks (default: 32G)
- `-m, --memory MEMORY`: VM memory in MB (default: 8192)
- `-c, --cores CORES`: Number of CPU cores (default: 4)
- `-u, --username USERNAME`: Username for cloud-init (default: distro-specific)
- `-p, --password PASSWORD`: Password for cloud-init (default: empty, use CLOUD_INIT_PASSWORD)
- `-k, --ssh-key SSH_KEY`: Path to SSH public key file (default: empty, use SSH_KEY_PATH)
- `-f, --failed-only`: Only create templates for distributions that failed previously
- `-l, --list`: List supported distributions and their default VM IDs
- `-h, --help`: Display help message
- `--debug`: Enable debug logging
- `--dry-run`: Show what would be done without executing

### Workflow

1. The script checks for existing templates and skips them
2. Processes each distribution in sequence
3. Provides real-time feedback on progress
4. Generates a summary of successful and failed creations
5. Failed distributions can be retried with the `-f` flag

### Example Output

```
🚀 Starting VM template creation for all distributions
ℹ️  [INFO] 2025-10-30 00:35:59 - Processing distributions: debian fedora ubuntu alpine centos tumbleweed
ℹ️  [INFO] 2025-10-30 00:35:59 - Creating template for debian...
✅ [SUCCESS] 2025-10-30 00:36:15 - debian template created successfully

ℹ️  [INFO] 2025-10-30 00:36:15 - Creating template for fedora...
✅ [SUCCESS] 2025-10-30 00:36:32 - fedora template created successfully

📊 Summary:
✅ [SUCCESS] 2025-10-30 00:37:45 - Successfully created templates for: debian fedora ubuntu alpine centos tumbleweed
✅ [SUCCESS] 2025-10-30 00:37:45 - All templates created successfully!
```

## vm-create-all Script Features

The `vm-create-all` script automates the creation of VMs from all available VM templates in a single run.

### Features

- **Batch VM creation**: Creates VMs from all available templates at once
- **Template validation**: Checks if templates exist before attempting to clone
- **Incremental VM ID assignment**: Assigns VM IDs incrementally starting from a specified ID
- **Selective creation**: Option to retry only failed distributions
- **Dry-run mode**: Preview what would be done without executing
- **Progress tracking**: Shows which distributions are being processed
- **Error handling**: Continues with other distributions if one fails
- **Summary reporting**: Provides detailed success/failure summary

### VM ID Assignment

The script assigns VM IDs incrementally starting from a specified ID (default: 111):
- If starting VM ID is 111: Debian → 111, Fedora → 112, Ubuntu → 113, etc.
- If starting VM ID is 121: Debian → 121, Fedora → 122, Ubuntu → 123, etc.
- The script automatically increments the VM ID for each distribution in the order:
  debian, fedora, ubuntu, alpine, centos, tumbleweed, arch

### Usage Examples

```bash
# Create all VMs with default settings (starting from VM ID 111)
./vm-create-all

# Create all VMs starting from VM ID 121
./vm-create-all -i 121

# Create all VMs using custom storage and start from VM ID 151
./vm-create-all -s local-zfs -i 151

# Only retry distributions that failed previously
./vm-create-all -f

# Preview what would be done without executing
./vm-create-all --dry-run

# List all supported distributions and their template/VM ID mappings
./vm-create-all --list
```

### Command Line Options

- `-s, --storage STORAGE`: Proxmox storage target for cloned VMs (default: local-lvm)
- `-i, --start-vm-id START_VM_ID`: Starting VM ID for incremental assignment (default: 111)
- `-f, --failed-only`: Only create VMs for distributions that failed previously
- `-l, --list`: List supported distributions and their template/VM ID mappings
- `-h, --help`: Display help message
- `--debug`: Enable debug logging
- `--dry-run`: Show what would be done without executing

### Workflow

1. The script checks for existing templates and skips distributions without templates
2. Assigns VM IDs incrementally starting from the specified starting ID
3. Checks if VMs already exist and skips them
4. Processes each distribution in sequence
5. Provides real-time feedback on progress
6. Generates a summary of successful and failed creations
7. Failed distributions can be retried with the `-f` flag

### Example Output

```
🚀 Starting VM creation from all templates
ℹ️  [INFO] 2025-10-30 00:45:12 - Processing distributions: debian fedora ubuntu alpine centos tumbleweed
ℹ️  [INFO] 2025-10-30 00:45:12 - Creating VM for debian from template 201...
✅ [SUCCESS] 2025-10-30 00:45:18 - debian VM created successfully (ID: 111)

ℹ️  [INFO] 2025-10-30 00:45:18 - Creating VM for fedora from template 202...
✅ [SUCCESS] 2025-10-30 00:45:25 - fedora VM created successfully (ID: 112)

📊 Summary:
✅ [SUCCESS] 2025-10-30 00:46:15 - Successfully created VMs for: debian fedora ubuntu alpine centos tumbleweed
✅ [SUCCESS] 2025-10-30 00:46:15 - All VMs created successfully!
```

### Advanced Usage

For more complex scenarios, you can combine options:

```bash
# Create VMs starting from ID 201 with custom storage and debug logging
./vm-create-all -i 201 -s local-zfs --debug

# Preview what would be done with custom starting ID
./vm-create-all -i 301 --dry-run --list
```

### Prerequisites

- VM templates must exist (run `vm-templates-create-all` first)
- Sufficient storage space on the target Proxmox storage
- Appropriate permissions in Proxmox

## License

This script is provided as-is for educational and production use.
