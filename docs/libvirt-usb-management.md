# Libvirt VM USB Device Management

This guide explains how to manage USB devices for libvirt VMs using the enhanced `vm` script.

## Overview

The `vm` script now provides comprehensive USB device management for libvirt VMs, allowing you to:

- List available USB devices on the host system
- Attach USB devices to running VMs
- Detach USB devices from VMs
- Support multiple device identification formats

## Prerequisites

- Libvirt installed and running
- VM must be running to attach/detach devices
- `lsusb` command available (install `usbutils` package)
- Proper permissions to access USB devices and libvirt

## USB Management Commands

### List Available USB Devices

```bash
# List all USB devices on the host
vm usb-list
```

Example output:
```
USB devices available on host:

Format: Bus Device ID: Vendor:Product Description
────────────────────────────────────────────────────────────────
001 001    1d6b:0002 Linux Foundation 2.0 root hub
001 004    046d:c53f Logitech, Inc. USB Receiver
001 005    05ac:024f Apple, Inc. Aluminium Keyboard (ANSI)
002 002    04e8:61f5 Samsung Electronics Co., Ltd Portable SSD T5
002 003    0781:5583 SanDisk Corp. Ultra Fit

Usage examples:
  By USB ID: vm usb-attach VM_NAME vendor:product
  By Bus/Device: vm usb-attach VM_NAME bus.device
```

### List Attached USB Devices

```bash
# List USB devices currently attached to a VM
vm usb-attached VM_NAME
```

### Attach USB Device

```bash
# Attach by vendor:product ID (recommended)
vm usb-attach VM_NAME 0781:5583

# Attach by bus.device format
vm usb-attach VM_NAME 002.003

# Attach with optional device name
vm usb-attach VM_NAME 0781:5583 sandisk-drive
```

### Detach USB Device

```bash
# Detach by vendor:product ID
vm usb-detach VM_NAME 0781:5583

# Detach by bus.device format
vm usb-detach VM_NAME 002.003
```

## Device Identification Formats

The script supports two main device identification methods:

### 1. Vendor:Product ID Format (Recommended)
```bash
vm usb-attach debian 0781:5583
```
- Most reliable method
- Use `lsusb` to find vendor:product IDs
- Format: `vendorid:productid` (hexadecimal)
- Remains consistent even if device is unplugged/replugged

### 2. Bus.Device Format
```bash
vm usb-attach debian 002.003
```
- Based on current USB bus topology
- May change if device is unplugged/replugged
- Format: `bus.device` (decimal)
- Use for temporary attachments

## Real-World Usage Examples

### USB Storage Device Management

```bash
# 1. List available USB devices
vm usb-list

# 2. Attach SanDisk USB drive to running VM
vm usb-attach debian 0781:5583

# 3. Inside VM: device appears as /dev/sdb
vm ssh debian
sudo mkdir /mnt/usb
sudo mount /dev/sdb1 /mnt/usb
ls /mnt/usb

# 4. When done: unmount inside VM first, then detach
sudo umount /mnt/usb
exit
vm usb-detach debian 0781:5583
```

### USB Input Device Management

```bash
# Attach Logitech USB receiver
vm usb-attach debian 046d:c53f

# Attach Apple keyboard
vm usb-attach debian 05ac:024f

# Later detach devices
vm usb-detach debian 046d:c53f
vm usb-detach debian 05ac:024f
```

### USB Serial Device Management

```bash
# Attach USB-to-serial adapter
vm usb-attach debian 0403:6001

# Inside VM: device appears as /dev/ttyUSB0
vm ssh debian
sudo dmesg | tail
ls /dev/ttyUSB*

# When done, detach
vm usb-detach debian 0403:6001
```

## Technical Implementation

### XML Configuration

The script creates libvirt XML configurations for USB devices:

**Vendor:Product ID format:**
```xml
<hostdev mode='subsystem' type='usb' managed='yes'>
  <source>
    <vendor id='0x0781'/>
    <product id='0x5583'/>
  </source>
</hostdev>
```

**Bus.Device format:**
```xml
<hostdev mode='subsystem' type='usb' managed='yes'>
  <source>
    <address bus='2' device='3'/>
  </source>
</hostdev>
```

### Live Attachment/Detachment

- Uses `virsh attach-device --live` for hot-plugging
- Uses `virsh detach-device --live` for hot-unplugging
- No VM restart required
- Changes are immediately visible inside the VM

## Integration with VM Management

The USB commands are fully integrated with the existing `vm` script:

```bash
# Complete VM workflow with USB
vm create --distro debian --name my-debian
vm start my-debian
vm usb-attach my-debian 0781:5583
vm ssh my-debian
# ... work with USB device inside VM ...
vm usb-detach my-debian 0781:5583
vm stop my-debian
```

## Troubleshooting

### Device Not Found
```bash
# Error: Device not found
# Solution: Check if device is still connected
lsusb | grep DEVICE_ID
```

### VM Not Running
```bash
# Error: VM is not running
# Solution: Start the VM first
vm start VM_NAME
```

### Permission Denied
```bash
# Error: Permission denied
# Solution: Ensure user is in libvirt group
sudo usermod -a -G libvirt $USER
# Log out and back in, or run:
newgrp libvirt
```

### Device Already in Use
```bash
# Error: Device busy or already attached
# Solution: Check if device is attached to another VM
vm usb-attached OTHER_VM_NAME
# Or check host processes using the device
lsof | grep /dev/bus/usb
```

### Attachment Failed
```bash
# Error: Failed to attach device
# Solution: Check VM state and device availability
vm status VM_NAME
lsusb | grep DEVICE_ID
```

## Best Practices

1. **Use Vendor:Product ID format when possible**
   ```bash
   vm usb-attach debian 0781:5583  # Preferred
   ```

2. **Always unmount inside VM before detaching**
   ```bash
   # Inside VM
   sudo umount /mnt/usb
   
   # On host
   vm usb-detach debian 0781:5583
   ```

3. **Check device status before operations**
   ```bash
   vm status debian
   vm usb-list
   ```

4. **Use descriptive names for complex setups**
   ```bash
   vm usb-attach debian 0781:5583 backup-drive
   ```

## Security Considerations

- USB device passthrough gives the VM direct access to the hardware
- Malicious USB devices could potentially compromise the VM
- Only attach trusted USB devices
- Consider the security implications of USB storage devices
- USB devices attached to VMs are not accessible to the host

## Limitations

- Only works with running VMs
- Some specialized USB devices may not work properly in VMs
- USB device hotplug may not work perfectly with all guest operating systems
- Bus.Device format may change if device is unplugged/replugged

## Complete Example Workflow

```bash
# 1. Create and start a VM
vm create --distro ubuntu --name usb-test
vm start usb-test

# 2. List available USB devices
vm usb-list

# 3. Attach a USB storage device
vm usb-attach usb-test 0781:5583

# 4. Access the VM and use the device
vm ssh usb-test
sudo mkdir /mnt/usb
sudo mount /dev/sdb1 /mnt/usb
ls /mnt/usb
# ... work with files ...
sudo umount /mnt/usb
exit

# 5. Detach the device
vm usb-detach usb-test 0781:5583

# 6. Clean up
vm stop usb-test
vm delete usb-test
```

This comprehensive USB management system provides enterprise-grade USB device control for your libvirt VMs with excellent usability and safety features!
