# Extra Goodies

This directory contains additional configurations and scripts that you might find useful.

## VM

The `vms` directory contains a NixOS configuration for a basic VM. It includes a basic NixOS configuration with a few useful packages.

To build the VM image, run the following command:

```bash
nix build .#packages.x86_64-linux.vm
```

To run the VM, use the `run-nixos-vm` script from the root directory of this repository.

```bash
./result/bin/run-nixos-vm
```

To build and run the VM in a VM in one go, use the `build-vm` script from the root directory of this repository.

```bash
./build-vm
```

## Router

The `router` directory contains a NixOS configuration for a hardened router. It includes nftables, dnsmasq, WireGuard, VRRP failover, centralized logging, alerting, and monitoring.

To build the router image, run the following command:

```bash
nix build .#packages.x86_64-linux.router-image
```

To run the router in a VM, use the `run-nixos-vm` script from the root directory of this repository.

```bash
./result/bin/run-nixos-vm
```

To build and run the router in a VM in one go, use the `build-router` script from the root directory of this repository.

```bash
./build-router
```
