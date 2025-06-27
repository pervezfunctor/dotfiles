#!/bin/bash

# Usage: ./setup_bindmount.sh /host/data/dir 101 102 103

set -e

if [ $# -lt 2 ]; then
  echo "Usage: $0 <host_directory> <ctid1> [ctid2 ...]"
  exit 1
fi

HOST_DIR="$1"
shift
CTIDS=("$@")

# Create the directory on the host if it doesn't exist
mkdir -p "$HOST_DIR"

# Set permissions for the first container (assumes UID 1000 in container)
# If you want to support different UIDs in each container, adjust accordingly.
HOST_UID=$((100000 + 1000))
HOST_GID=$((100000 + 1000))
chown -R $HOST_UID:$HOST_GID "$HOST_DIR"
chmod 2775 "$HOST_DIR"

for CTID in "${CTIDS[@]}"; do
  # Set bind mount in container config
  # Mount point number (mp0, mp1, ...) is chosen automatically; adjust as needed
  # We'll use mp0 unless it already exists
  CONF="/etc/pve/lxc/$CTID.conf"
  MP_IDX=0
  while grep -q "^mp$MP_IDX:" "$CONF"; do
    MP_IDX=$((MP_IDX + 1))
  done
  # Mount to /data in container (change as needed)
  echo "mp$MP_IDX: $HOST_DIR,mp=/data" >>"$CONF"
  echo "Added bind mount to $CONF as mp$MP_IDX"
done

echo "Bind mount and permissions set up successfully."
