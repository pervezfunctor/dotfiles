# Hardened NixOS Router - README

This guide will help you set up a **bare-metal NixOS-based router** using a flake-based configuration. This includes:

* nftables-based firewall
* dnsmasq (DHCP + DNS)
* WireGuard VPN
* Keepalived for VRRP failover
* Centralized logging
* Prometheus + Alertmanager

---

## 🧰 Requirements

* A physical machine with two NICs (e.g. `wan0`, `lan0`)
* NixOS 24.05 or later
* [Flakes enabled](https://nixos.wiki/wiki/Flakes)
* Secrets encrypted using [agenix](https://github.com/ryantm/agenix)
* SSH public/private key pair

---

## 📁 Directory Layout

```
router-flake/
├── flake.nix
├── flake.lock
├── secrets/
│   └── wg-private.age
├── README.md
```

---

## 🚀 Setup Instructions

### 1. Clone the repo

```bash
git clone https://github.com/yourusername/router-flake
cd router-flake
```

### 2. Generate SSH Key (for user login)

```bash
ssh-keygen -t ed25519 -C "router access"
```

Copy the **public key** and paste it in `users.users.router.openssh.authorizedKeys.keys` in the flake config.

### 3. Encrypt your WireGuard private key

```bash
mkdir -p secrets

# Generate key if needed:
umask 077 && wg genkey > secrets/wg-private

# Encrypt with agenix:
agenix -e secrets/wg-private
```

The result should be `wg-private.age`, and the path in `flake.nix` should point to it.

### 4. Fix sha256 for `nixos-generators`

Run this:

```bash
nix build .#packages.x86_64-linux.router-image
```

If you see an error like this:

```
error: hash mismatch in fixed-output derivation
expected: sha256-AAAAAAAAAAAAAAAAAAA...
actual:   sha256-xxxxxxxxxxxxxxxxxxx...
```

Update the `sha256 = "..."` field in your `flake.nix` with the `actual` hash.

---

## 🏗️ Build the Router Image

```bash
nix build .#packages.x86_64-linux.router-image
```

The image will be available under `./result/`. You can flash it to USB:

```bash
sudo dd if=./result/iso/*router.iso of=/dev/sdX bs=4M status=progress
```

Replace `/dev/sdX` with your USB device.

---

## 🔒 Security Tips

* Never allow root login or password auth via SSH.
* Use `age` or `sops-nix` for secret management.
* Always verify the WireGuard private key is properly encrypted and only accessible to root.
* Use an external Prometheus/Grafana stack for full observability.

---

## 🧠 Notes

* You can test this in a Proxmox VM with two bridged NICs before bare-metal deployment.
* This config supports seamless HA if deployed on two nodes with VRRP enabled.
* Modify `keepalived` priorities to define master/backup.

---

## 🔧 Useful Commands

```bash
# Test firewall
sudo nft list ruleset

# Check DHCP leases
cat /var/lib/misc/dnsmasq.leases

# WireGuard status
sudo wg show

# View logs
journalctl -u dnsmasq
journalctl -u keepalived
journalctl -u prometheus-node-exporter
```

---

## 🧪 Troubleshooting

* **Missing sha256**: Let `nix` fail once, then copy the correct hash.
* **No network on boot**: Double-check interface names (use `ip a` or `udevadm test /sys/class/net/eth0`).
* **VRRP IP not active**: Make sure both routers are on and `keepalived` is running.

---

## 📬 Contact

Questions or improvements? File a GitHub issue or contact me via email.

---

Enjoy your hardened, reproducible, and headless NixOS router! 🛡️
