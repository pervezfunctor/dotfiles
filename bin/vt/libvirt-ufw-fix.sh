#!/usr/bin/env bash
set -euo pipefail -o errtrace

echo "[*] Configuring UFW for libvirt..."

# Ensure ufw is enabled
ufw status >/dev/null 2>&1 || ufw enable

# --- 1. Allow DHCP replies (libvirt-dnsmasq -> VMs) ---
# DHCP uses UDP 67/68 inside virtual networks.
echo "[*] Allowing DHCP (67/udp, 68/udp)"
ufw allow in on virbr0 to any port 67 proto udp
ufw allow in on virbr0 to any port 68 proto udp

# --- 2. Allow DNS for guests (libvirt-dnsmasq) ---
echo "[*] Allowing DNS (53/udp)"
ufw allow in on virbr0 to any port 53 proto udp

# --- 3. Optional: allow VM → host SSH ---
# Uncomment if you want to SSH from guests into host.
# ufw allow in on virbr0 to any port 22 proto tcp

# --- 4. Disable UFW from interfering with libvirt NAT ---
# Ensure ufw forwards packets for NAT bridge.
UFW_SYSCTL="/etc/ufw/sysctl.conf"
if ! grep -q "^net/ipv4/ip_forward=1" "$UFW_SYSCTL"; then
  echo "[*] Enabling IPv4 forwarding in $UFW_SYSCTL"
  echo "net/ipv4/ip_forward=1" >>"$UFW_SYSCTL"
fi

# --- 5. Ensure before.rules has MASQUERADE for virbr0 ---
UFW_BEFORE_RULES="/etc/ufw/before.rules"
if ! grep -q "POSTROUTING.*-o virbr0 -j MASQUERADE" "$UFW_BEFORE_RULES"; then
  echo "[*] Adding NAT masquerade for virbr0 in $UFW_BEFORE_RULES"
  sed -i '/^*nat$/,/^COMMIT$/ {
        /:POSTROUTING ACCEPT/ a -A POSTROUTING -s 192.168.122.0/24 -o virbr0 -j MASQUERADE
    }' "$UFW_BEFORE_RULES"
fi

# --- 6. Reload ufw ---
echo "[*] Reloading ufw..."
ufw reload

echo "[+] UFW configured for libvirt."
