#!/bin/bash

set -e

LIBVIRT_NET="virbr0"
LIBVIRT_SUBNET="192.168.122.0/24"

if [ -z "$1" ]; then
  echo "Error: Please provide the outgoing interface (e.g., eth0) as an argument."
  echo "Usage: $0 <OUT_IF> (e.g. eth0)"
  exit 1
fi

OUT_IF=$1

echo "Flushing existing FORWARD rules for libvirt and docker chains..."
iptables -D FORWARD -i $LIBVIRT_NET -o "$OUT_IF" -j ACCEPT 2>/dev/null || true
iptables -D FORWARD -i "$OUT_IF" -o $LIBVIRT_NET -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || true

iptables -A FORWARD -i $LIBVIRT_NET -o "$OUT_IF" -j ACCEPT
iptables -A FORWARD -i "$OUT_IF" -o $LIBVIRT_NET -m state --state RELATED,ESTABLISHED -j ACCEPT

echo "Setting up NAT (MASQUERADE) for libvirt subnet..."
iptables -t nat -D POSTROUTING -s $LIBVIRT_SUBNET ! -o $LIBVIRT_NET -j MASQUERADE 2>/dev/null || true
iptables -t nat -A POSTROUTING -s $LIBVIRT_SUBNET ! -o $LIBVIRT_NET -j MASQUERADE

echo "Done. You should now have internet access from libvirt guests alongside Docker."

# Optionally, show the rules summary
echo
echo "Current FORWARD chain rules (summary):"
iptables -L FORWARD -v -n | grep -E "$LIBVIRT_NET|$OUT_IF"

echo
echo "Current POSTROUTING nat rules (summary):"
iptables -t nat -L POSTROUTING -v -n | grep MASQUERADE
