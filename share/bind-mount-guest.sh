#!/bin/bash

# Usage: ./create_bindmount_dir.sh /host/data/dir [container_uid]
# If container_uid is not provided, defaults to 1000 (standard first user in LXC).

set -e

if [ $# -lt 1 ]; then
  echo "Usage: $0 <host_directory> [container_uid]"
  exit 1
fi

HOST_DIR="$1"
CONTAINER_UID="${2:-1000}" # Default to 1000 if not specified

# Calculate mapped UID/GID for unprivileged LXC (host = container + 100000)
HOST_UID=$((100000 + CONTAINER_UID))
HOST_GID=$((100000 + CONTAINER_UID))

# Create directory if it doesn't exist
mkdir -p "$HOST_DIR"

# Set ownership and permissions for LXC bind mount usage
chown -R $HOST_UID:$HOST_GID "$HOST_DIR"
chmod 2775 "$HOST_DIR"

echo "Directory $HOST_DIR created and permissions set for LXC UID/GID $CONTAINER_UID (host-mapped $HOST_UID:$HOST_GID)."
echo "You can now bind mount this directory into your LXC container."
