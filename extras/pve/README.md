# VM Template Creator for Proxmox VE

This repository contains scripts that automate the creation of VM templates in Proxmox VE, with enhanced security and robustness features.

## Scripts

### debian-vm-template
Creates Debian VM templates in Proxmox VE.

### vm-template
Creates VM templates for multiple distributions (Debian, Fedora, Ubuntu, Alpine, CentOS) in Proxmox VE.

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

### Usage Examples

```bash
# Create a Debian template
./vm-template -D debian

# Create an Ubuntu template with SSH key
./vm-template -D ubuntu -k ~/.ssh/id_rsa.pub -m 4096 -c 2

# Create a Fedora template with custom settings
./vm-template -D fedora -i 1001 -n my-fedora-template -C "sha256:abcdef..."

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

## License

This script is provided as-is for educational and production use.
