# PVE (Proxmox Virtual Environment) Management Tools

The PVE toolset provides comprehensive solutions for managing Proxmox virtual machines and containers through the Proxmox VE API. It consists of three main components:

- [`pvm`](../../../extras/pve/pvm) - QEMU Virtual Machine management interface
- [`pxc`](../../../extras/pve/pxc) - LXC Container management interface
- [`pve-api-user`](../../../extras/pve/pve-api-user) - API user management utility

## Overview

PVE (Proxmox Virtual Environment) is a set of bash-based tools that simplify the management of Proxmox virtual machines and containers by providing a familiar command-line interface. It supports creating, managing, and interacting with VMs and containers through the Proxmox VE REST API.

## Installation

### Prerequisites

- Proxmox VE server with API access
- Bash shell
- SSH key pair for VM/container access
- `curl` and `jq` packages installed

### Configuration

Before using PVE tools, you need to configure the connection to your Proxmox server. You can configure it in multiple ways:

#### Method 1: Configuration File (Recommended)

Create a configuration file at `~/.pverc` or specify a custom location with the `PVE_CONFIG_FILE` environment variable:

```bash
# ~/.pverc
PVE_HOST="https://your-proxmox-server:8006"
TOKEN_ID="your-user@pve!your-token-name"
TOKEN_SECRET="your-api-token-secret"
NODE_NAME="your-node-name"  # leave empty to autodetect
SSH_DEFAULT_USER="your-ssh-user"
```

#### Method 2: Environment Variables

You can also set configuration using environment variables:

```bash
export PVE_HOST="https://your-proxmox-server:8006"
export TOKEN_ID="your-user@pve!your-token-name"
export TOKEN_SECRET="your-api-token-secret"
export NODE_NAME="your-node-name"
export SSH_DEFAULT_USER="your-ssh-user"
```

#### Method 3: Edit Script (Legacy)

You can still edit the scripts directly and update the configuration section at the top of each file.

#### Installation

1. Make the scripts executable:
   ```bash
   chmod +x extras/pve/pvm extras/pve/pxc extras/pve/pve-api-user
   ```

2. Optionally, create symbolic links in a directory in your PATH:
   ```bash
   sudo ln -s /path/to/extras/pve/pvm /usr/local/bin/pvm
   sudo ln -s /path/to/extras/pve/pxc /usr/local/bin/pxc
   sudo ln -s /path/to/extras/pve/pve-api-user /usr/local/bin/pve-api-user
   ```

**Configuration Priority**: Environment variables take precedence over the configuration file, which takes precedence over default values in scripts.

For PVM (VM management):
```bash
cp extras/pve/pvmrc.example ~/.pvmrc
# Then edit ~/.pvmrc with your settings
```

For PXC (container management):
```bash
cp extras/pve/pxcrc.example ~/.pverc
# Then edit ~/.pverc with your settings
```

## VM Management Tool: pvm

The `pvm` script is the primary interface for managing Proxmox QEMU VMs. It provides a comprehensive set of commands for VM lifecycle management.

### Basic Usage

```bash
pvm <command> [args...]
```

### Commands

#### VM Lifecycle Management

| Command             | Description                                             | Example                                                         |
| ------------------- | ------------------------------------------------------- | --------------------------------------------------------------- |
| `list`              | List all Proxmox VMs                                    | `pvm list`                                                      |
| `status <vmid>`     | Show VM status and info                                 | `pvm status 100`                                                |
| `start [vmid...]`   | Start VM(s) - if no VM IDs provided, select from list   | `pvm start 100`<br>`pvm start 100 101 102`<br>`pvm start`       |
| `stop [vmid...]`    | Stop VM(s) - if no VM IDs provided, select from list    | `pvm stop 100`<br>`pvm stop 100 101 102`<br>`pvm stop`          |
| `restart [vmid...]` | Restart VM(s) - if no VM IDs provided, select from list | `pvm restart 100`<br>`pvm restart 100 101 102`<br>`pvm restart` |
| `shutdown <vmid>`   | Gracefully shutdown a VM                                | `pvm shutdown 100`                                              |
| `delete [vmid...]`  | Delete VM(s) - if no VM IDs provided, select from list  | `pvm delete 100`<br>`pvm delete 100 101 102`<br>`pvm delete`    |

#### VM Interaction

| Command                 | Description           | Example             |
| ----------------------- | --------------------- | ------------------- |
| `console <vmid>`        | Connect to VM console | `pvm console 100`   |
| `ip <vmid>`             | Get VM IP address     | `pvm ip 100`        |
| `ssh <vmid> <username>` | Connect to VM via SSH | `pvm ssh 100 admin` |

#### VM Information

| Command         | Description                  | Example          |
| --------------- | ---------------------------- | ---------------- |
| `info <vmid>`   | Show detailed VM information | `pvm info 100`   |
| `config <vmid>` | Show VM configuration        | `pvm config 100` |

#### Snapshot Management

| Command                          | Description              | Example                               |
| -------------------------------- | ------------------------ | ------------------------------------- |
| `snapshot-list <vmid>`           | List VM snapshots        | `pvm snapshot-list 100`               |
| `snapshot-create <vmid> <name>`  | Create VM snapshot       | `pvm snapshot-create 100 backup-001`  |
| `snapshot-restore <vmid> <name>` | Restore VM from snapshot | `pvm snapshot-restore 100 backup-001` |
| `snapshot-delete <vmid> <name>`  | Delete VM snapshot       | `pvm snapshot-delete 100 backup-001`  |

#### Utility Commands

| Command     | Description            | Example         |
| ----------- | ---------------------- | --------------- |
| `node-list` | List all Proxmox nodes | `pvm node-list` |
| `version`   | Show PVE version info  | `pvm version`   |

### Examples

```bash
# List all VMs
pvm list

# Start a VM and check its status
pvm start 100
pvm status 100

# Multi-VM operations
pvm start 100 101 102    # Start multiple VMs
pvm stop                 # Select VMs to stop from menu
pvm restart 100 101      # Restart multiple VMs
pvm delete               # Select VMs to delete from menu

# Get VM IP and connect via SSH
pvm ip 100
pvm ssh 100 admin

# Create and manage snapshots
pvm snapshot-create 100 backup-001
pvm snapshot-list 100
pvm snapshot-restore 100 backup-001

# Get detailed VM information
pvm info 100
pvm config 100
```

## Container Management Tool: pxc

The `pxc` script is used for managing Proxmox LXC containers. It provides a comprehensive set of commands for container lifecycle management.

### Basic Usage

```bash
pxc <command> [args...]
```

### Commands

#### Container Lifecycle Management

| Command          | Description                 | Example           |
| ---------------- | --------------------------- | ----------------- |
| `list`           | List all Proxmox containers | `pxc list`        |
| `start <ctid>`   | Start a container           | `pxc start 100`   |
| `stop <ctid>`    | Stop a container            | `pxc stop 100`    |
| `restart <ctid>` | Restart a container         | `pxc restart 100` |

#### Container Interaction

| Command                 | Description                  | Example             |
| ----------------------- | ---------------------------- | ------------------- |
| `ip <ctid>`             | Get container IP address     | `pxc ip 100`        |
| `ssh <ctid> <username>` | Connect to container via SSH | `pxc ssh 100 admin` |

### Examples

```bash
# List all containers
pxc list

# Start a container
pxc start 100

# Get container IP and connect via SSH
pxc ip 100
pxc ssh 100 admin
```

## Features

### API Integration

- Direct integration with Proxmox VE REST API
- Secure token-based authentication
- Automatic node detection
- Comprehensive error handling

### Multi-VM/Container Operations

- Batch operations on multiple VMs/containers
- Interactive selection interface
- Individual validation for each target
- Confirmation prompts for destructive operations

### Network Management

- Automatic IP address detection via QEMU agent or LXC interfaces
- SSH connection support with automatic IP resolution
- Network interface information

### Security Features

- Token-based API authentication
- Secure SSH key-based VM/container access
- No password storage in scripts

## Troubleshooting

### Common Issues

1. **Permission denied errors**
   - Verify your API token has sufficient permissions
   - Check that the token is not expired
   - Ensure the user has proper roles in Proxmox

2. **VM/container operations fail**
   - Check network connectivity to Proxmox server
   - Verify VM/container ID exists and is accessible
   - Ensure QEMU agent is installed and running for IP detection

3. **SSH connection issues**
   - Verify SSH key is properly configured
   - Check VM/container network configuration
   - Ensure SSH service is running in the VM/container
   - Verify QEMU agent is installed and running

4. **API connection issues**
   - Check Proxmox server URL and port
   - Verify token credentials
   - Check SSL certificate settings

### Getting Help

```bash
# Get help for pvm
pvm

# Get help for pxc
pxc
```

## Integration with Other Tools

PVE tools integrate seamlessly with:
- **Proxmox VE** - Virtualization platform
- **SSH** - Standard SSH client for VM/container access
- **QEMU Agent** - For VM IP detection and management
- **curl** - For API communication
- **jq** - For JSON processing

## Best Practices

1. **Configuration Management**: Use configuration files instead of editing scripts directly
2. **Token Security**: Store API tokens securely and limit permissions
3. **Resource Planning**: Monitor VM/container resource usage
4. **Regular Snapshots**: Create snapshots before major changes
5. **Security**: Use SSH keys instead of passwords when possible
6. **Monitoring**: Regularly check VM/container status and logs
7. **Cleanup**: Remove unused VMs/containers to free up resources

## API Token Setup

To create an API token in Proxmox VE:

1. Log in to the Proxmox web interface
2. Go to Datacenter → Permissions → API Tokens
3. Add a new API token for your user
4. Set appropriate permissions (e.g., VM.Audit, VM.Console, VM.PowerMgmt, VM.Snapshot)
5. Note the Token ID and Secret for configuration

## Contributing

The PVE toolset is part of the larger dotfiles configuration. Contributions and improvements are welcome through the standard project contribution process.
