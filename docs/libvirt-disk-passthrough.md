# Libvirt Disk Passthrough Management

This document describes how to use the disk passthrough functionality in the `vm` script to attach raw block devices (physical disks, SSDs, NVMe drives) directly to libvirt VMs.

## Overview

Disk passthrough allows you to attach physical storage devices directly to VMs, providing:
- **Direct hardware access** - VM gets raw access to the physical device
- **Better performance** - No virtualization overhead for storage I/O
- **Hardware-specific features** - Access to device-specific capabilities (TRIM, etc.)
- **Hot-plug support** - Attach/detach disks while VM is running

## Commands

### List Available Disks

```bash
# List all block devices available on the host
vm disk-list
```

Example output:
```
Block devices available on host:

Format: NAME SIZE TYPE MOUNTPOINT MODEL
────────────────────────────────────────────────────────────────
sda     465.8G disk            Samsung Portable SSD T5
nvme0n1 931.5G disk            Samsung SSD 980 1TB

Usage examples:
  Attach disk: vm disk-attach VM_NAME /dev/sdX
  Attach NVMe: vm disk-attach VM_NAME /dev/nvme0n1

WARNING: Only attach unmounted disks to avoid data corruption!
Check mount status with: lsblk -f /dev/DEVICE
```

### List Attached Disks

```bash
# List disk devices currently attached to a VM
vm disk-attached VM_NAME
```

### Attach Disk Device

```bash
# Attach a raw disk device to a running VM
vm disk-attach VM_NAME /dev/DEVICE [name]

# Examples:
vm disk-attach ubuntu /dev/sdb
vm disk-attach debian /dev/nvme1n1
vm disk-attach fedora /dev/sdc storage-disk
```

### Detach Disk Device

```bash
# Detach a disk device from a running VM
vm disk-detach VM_NAME /dev/DEVICE

# Examples:
vm disk-detach ubuntu /dev/sdb
vm disk-detach debian /dev/nvme1n1
```

## Supported Device Types

The script supports all standard Linux block devices:

- **SATA/SCSI disks**: `/dev/sda`, `/dev/sdb`, etc.
- **NVMe drives**: `/dev/nvme0n1`, `/dev/nvme1n1`, etc.
- **MMC/SD cards**: `/dev/mmcblk0`, `/dev/mmcblk1`, etc.
- **USB storage**: `/dev/sdc`, `/dev/sdd`, etc.

## Safety Features

### Automatic Mount Checking

The script automatically checks if a device is mounted before attachment:

```bash
vm disk-attach ubuntu /dev/sdb
# Error: Device /dev/sdb is currently mounted!
# Unmount the device before attaching to VM:
#   sudo umount /dev/sdb
```

### Partition Mount Checking

It also checks for mounted partitions:

```bash
vm disk-attach ubuntu /dev/sdb
# Error: Device /dev/sdb has mounted partitions:
# /dev/sdb1 on /mnt/backup type ext4 (rw,relatime)
# Unmount all partitions before attaching to VM
```

## Real-World Usage Examples

### External SSD for VM Storage

```bash
# 1. List available disks
vm disk-list

# 2. Ensure the SSD is not mounted
lsblk -f /dev/sdb
sudo umount /dev/sdb1  # if mounted

# 3. Attach to running VM
vm disk-attach ubuntu /dev/sdb

# 4. Inside VM: device appears as /dev/vdb
vm ssh ubuntu
sudo lsblk | grep vdb
sudo mkfs.ext4 /dev/vdb
sudo mkdir /mnt/external
sudo mount /dev/vdb /mnt/external

# 5. When done: unmount inside VM first, then detach
sudo umount /mnt/external
exit
vm disk-detach ubuntu /dev/sdb
```

### NVMe Drive for High-Performance Storage

```bash
# Attach NVMe drive for database storage
vm disk-attach postgres /dev/nvme1n1

# Inside VM: set up for PostgreSQL
vm ssh postgres
sudo mkfs.ext4 /dev/vdb
sudo mkdir /var/lib/postgresql/data
sudo mount /dev/vdb /var/lib/postgresql/data
sudo chown postgres:postgres /var/lib/postgresql/data
```

### USB Drive for Data Transfer

```bash
# Attach USB drive temporarily
vm disk-attach debian /dev/sdc

# Inside VM: mount and copy data
vm ssh debian
sudo mkdir /mnt/usb
sudo mount /dev/vdb1 /mnt/usb  # if already formatted
cp /home/user/data/* /mnt/usb/
sudo umount /mnt/usb

# Detach when done
exit
vm disk-detach debian /dev/sdc
```

## Technical Implementation

### XML Configuration

The script creates libvirt XML configurations for raw disk devices:

```xml
<disk type='block' device='disk'>
  <driver name='qemu' type='raw' cache='none' io='native'/>
  <source dev='/dev/sdb'/>
  <target dev='vdb' bus='virtio'/>
</disk>
```

### Device Naming

- Host devices: `/dev/sda`, `/dev/nvme0n1`, etc.
- Guest devices: `/dev/vdb`, `/dev/vdc`, etc. (virtio bus)
- Automatic target assignment starting from `vdb` (vda is main VM disk)

### Live Attachment/Detachment

- Uses `virsh attach-device --live` for hot-plugging
- Uses `virsh detach-device --live` for hot-unplugging
- No VM restart required
- Changes are immediately visible inside the VM

## Best Practices

1. **Always unmount before attaching**
   ```bash
   sudo umount /dev/sdb1
   vm disk-attach ubuntu /dev/sdb
   ```

2. **Check device status before operations**
   ```bash
   lsblk -f /dev/sdb
   vm status ubuntu
   ```

3. **Unmount inside VM before detaching**
   ```bash
   # Inside VM
   sudo umount /mnt/external
   
   # On host
   vm disk-detach ubuntu /dev/sdb
   ```

4. **Use appropriate filesystem options**
   ```bash
   # Inside VM - enable TRIM for SSDs
   sudo mount -o discard /dev/vdb /mnt/ssd
   ```

5. **Monitor device health**
   ```bash
   # Inside VM - check NVMe health
   sudo nvme smart-log /dev/vdb
   
   # Check SATA/SSD health
   sudo smartctl -a /dev/vdb
   ```

## Troubleshooting

### Device Not Found
```bash
# Error: Block device not found: /dev/sdb
# Solution: Check if device exists
lsblk | grep sdb
```

### Device Busy
```bash
# Error: Device /dev/sdb is currently mounted!
# Solution: Unmount the device
sudo umount /dev/sdb1
```

### Attachment Failed
```bash
# Error: Failed to attach disk device
# Solution: Check VM state and device permissions
vm status VM_NAME
ls -la /dev/sdb
```

### VM Not Running
```bash
# Error: VM 'ubuntu' is not running
# Solution: Start the VM first
vm start ubuntu
vm disk-attach ubuntu /dev/sdb
```

## Integration with VM Management

The disk commands are fully integrated with the existing `vm` script:

- Consistent error handling and logging
- Same safety checks as other VM operations
- Compatible with all VM management workflows
- Works with VMs created by `vm-create` scripts

## Security Considerations

- **Host access**: Attached devices bypass VM filesystem isolation
- **Data integrity**: Always unmount properly to prevent corruption
- **Permissions**: Ensure proper device permissions on host
- **Backup**: Consider backup implications for passed-through devices
