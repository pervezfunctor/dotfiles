# VM USB Device Management

This guide explains how to manage USB devices for Incus VMs using the `vm-usb` script.

## Overview

The `vm-usb` script provides comprehensive USB device management for Incus virtual machines, allowing you to:

- List available USB devices on the host system
- Attach USB devices to running VMs
- Detach USB devices from VMs
- Support multiple device identification formats

## Prerequisites

- Incus installed and running
- VM must be running (not containers)
- `lsusb` command available (install `usbutils` package)
- Proper permissions to access USB devices

## Basic Usage

### List Available USB Devices

```bash
# List all USB devices on the host
~/.ilm/bin/vt/vm-usb list
```

Example output:
```
USB devices available on host:

Format: Bus Device ID: Vendor:Product Description
────────────────────────────────────────────────────────────────
001 002    1d6b:0002 Linux Foundation 2.0 root hub
001 003    8087:0024 Intel Corp. Integrated Rate Matching Hub
002 001    1d6b:0003 Linux Foundation 3.0 root hub
003 002    046d:c52b Logitech, Inc. Unifying Receiver
```

### List Attached USB Devices

```bash
# List USB devices currently attached to a VM
~/.ilm/bin/vt/vm-usb list-attached VM_NAME
```

### Attach USB Device

```bash
# Attach by vendor:product ID
~/.ilm/bin/vt/vm-usb attach my-vm 046d:c52b

# Attach by bus.device format
~/.ilm/bin/vt/vm-usb attach my-vm 003.002

# Attach with custom device name
~/.ilm/bin/vt/vm-usb attach my-vm 046d:c52b --name my-mouse
```

### Detach USB Device

```bash
# Detach by device name
~/.ilm/bin/vt/vm-usb detach my-vm my-mouse

# List attached devices to see names
~/.ilm/bin/vt/vm-usb list-attached my-vm
```

## Device Identification Formats

The script supports multiple ways to identify USB devices:

### 1. Vendor:Product ID Format
```bash
vm-usb attach my-vm 1234:5678
```
- Most reliable method
- Use `lsusb` to find vendor:product IDs
- Format: `vendorid:productid` (hexadecimal)

### 2. Bus.Device Format
```bash
vm-usb attach my-vm 001.002
```
- Based on current USB bus topology
- May change if device is unplugged/replugged
- Format: `bus.device` (decimal)

### 3. Device Path Format
```bash
vm-usb attach my-vm /dev/bus/usb/001/002
```
- Full device path
- Equivalent to bus.device format
- Format: `/dev/bus/usb/BUS/DEVICE`

## Common Use Cases

### USB Storage Devices

```bash
# 1. List USB devices to find your storage device
vm-usb list

# 2. Attach the storage device (example: SanDisk USB drive)
vm-usb attach my-vm 0781:5567 --name usb-storage

# 3. Inside the VM, the device will appear as /dev/sdX
# Mount it inside the VM:
# sudo mkdir /mnt/usb
# sudo mount /dev/sdb1 /mnt/usb

# 4. When done, unmount inside VM first, then detach
vm-usb detach my-vm usb-storage
```

### USB Input Devices

```bash
# Attach a USB mouse
vm-usb attach my-vm 046d:c52b --name mouse

# Attach a USB keyboard
vm-usb attach my-vm 413c:2113 --name keyboard
```

### USB Serial Devices

```bash
# Attach USB-to-serial adapter
vm-usb attach my-vm 0403:6001 --name serial-adapter

# Inside VM, device will appear as /dev/ttyUSB0
```

## Integration with NixOS VMs

When creating NixOS VMs with `nixos-create`, USB management commands are automatically displayed:

```bash
# Create a NixOS VM
~/.ilm/bin/vt/nixos-create --type vm --name my-nixos-vm

# The script will show USB management commands in the final output:
# USB Device Management (VMs only):
#   List host USB: ~/.ilm/bin/vt/vm-usb list
#   List attached: ~/.ilm/bin/vt/vm-usb list-attached my-nixos-vm
#   Attach USB: ~/.ilm/bin/vt/vm-usb attach my-nixos-vm DEVICE
#   Detach USB: ~/.ilm/bin/vt/vm-usb detach my-nixos-vm DEVICE_NAME
```

## Troubleshooting

### Device Not Found
```bash
# Error: Device not found
# Solution: Check if device is still connected
lsusb | grep DEVICE_ID
```

### Permission Denied
```bash
# Error: Permission denied
# Solution: Add user to appropriate groups
sudo usermod -a -G plugdev $USER
# Log out and back in
```

### VM Not Running
```bash
# Error: VM is not running
# Solution: Start the VM first
incus start VM_NAME
```

### Device Already Attached
```bash
# Error: Device already attached
# Solution: Use different device name or detach first
vm-usb list-attached VM_NAME
vm-usb detach VM_NAME DEVICE_NAME
```

## Best Practices

1. **Always unmount inside VM before detaching**
   ```bash
   # Inside VM
   sudo umount /mnt/usb
   
   # On host
   vm-usb detach my-vm usb-storage
   ```

2. **Use descriptive device names**
   ```bash
   vm-usb attach my-vm 0781:5567 --name sandisk-64gb
   ```

3. **Check device compatibility**
   - Some USB devices may not work properly in VMs
   - USB 3.0 devices should work but may fall back to USB 2.0 speeds

4. **Monitor device usage**
   ```bash
   # Check what's attached
   vm-usb list-attached my-vm
   
   # Inside VM, check device recognition
   lsusb
   dmesg | tail
   ```

## Security Considerations

- USB device passthrough gives the VM direct access to the hardware
- Malicious USB devices could potentially compromise the VM
- Only attach trusted USB devices
- Consider the security implications of USB storage devices

## Limitations

- Only works with VMs (not containers)
- VM must be running to attach/detach devices
- Some specialized USB devices may not work properly
- USB device hotplug may not work perfectly with all guest operating systems

## Examples

### Complete USB Storage Workflow

```bash
# 1. Create a VM
nixos-create --type vm --name storage-vm

# 2. List available USB devices
vm-usb list

# 3. Attach USB storage device
vm-usb attach storage-vm 0781:5567 --name my-usb

# 4. Inside the VM, mount the device
incus exec storage-vm -- bash
mkdir /mnt/usb
mount /dev/sdb1 /mnt/usb
ls /mnt/usb

# 5. When done, unmount and detach
umount /mnt/usb
exit
vm-usb detach storage-vm my-usb
```

This comprehensive USB management system provides flexible and powerful USB device control for your Incus VMs!
