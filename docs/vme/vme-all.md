# vme-all - Batch VM Management Utility

The `vme-all` script provides batch operations for managing multiple VMs simultaneously. It's designed to quickly create, start, stop, or delete all standard distribution VMs.

## Usage

```bash
vme-all [command]
```

## Commands

- `create` - Create all standard VMs (Ubuntu, Fedora, Arch, Debian, Tumbleweed)
- `delete` - Delete all existing VMs
- `start` - Start all existing VMs
- `stop` - Stop all running VMs

## Supported VMs

The script manages these standard VMs by default:
- `ubuntu-vme` - Ubuntu VM
- `fedora-vme` - Fedora VM
- `arch-vme` - Arch Linux VM
- `debian-vme` - Debian VM
- `tw-vme` - openSUSE Tumbleweed VM

## Command Details

### create
Creates all standard VMs with default settings:
```bash
vme-all create
```

**Process:**
1. Checks if each VM already exists
2. Creates VM using `vme-create --distro <distro> --name <distro>-vme`
3. Skips VMs that already exist
4. Reports success/failure for each VM

### delete
Deletes all existing VMs:
```bash
vme-all delete
```

**Process:**
1. Iterates through all standard VM names
2. Deletes VM using `vm delete <vm-name>` for each existing VM
3. Reports deletion status for each VM

### start
Starts all existing VMs:
```bash
vme-all start
```

**Process:**
1. Checks which VMs exist
2. Starts each VM using `vm start <vm-name>`
3. Reports startup status for each VM

### stop
Stops all running VMs:
```bash
vme-all stop
```

**Process:**
1. Checks which VMs exist
2. Stops each VM using `vm stop <vm-name>`
3. Reports stop status for each VM

## Examples

```bash
# Create all standard VMs
vme-all create

# Start all VMs
vme-all start

# Stop all VMs
vme-all stop

# Delete all VMs
vme-all delete
```

## Use Cases

### Initial Setup
Perfect for setting up a complete development environment:
```bash
vme-all create
```

### Environment Management
Quickly manage multiple VMs:
```bash
# Start work environment
vme-all start

# Stop all when done
vme-all stop
```

### Cleanup
Remove all VMs when no longer needed:
```bash
vme-all delete
```

## Integration

The script integrates with:
- `vm-utils` - Core VM management functions
- `all-utils` - Batch operation utilities
- `vme-create` - Individual VM creation
- `vme` - Individual VM management

## Error Handling

The script handles these scenarios:
- VM already exists when creating - skips with warning
- VM doesn't exist when starting/stopping - skips with warning
- Provides clear success/failure messages for each operation
