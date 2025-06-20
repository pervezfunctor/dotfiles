# !/usr/bin/env bash

# Fix VS Code permissions issue in WSL
echo "Fixing VS Code permissions in WSL..."

# Create the temp directory with proper permissions if it doesn't exist
mkdir -p /tmp
sudo chmod 1777 /tmp

# Fix permissions for the specific file if it exists
if [ -f /tmp/remote-wsl-loc.txt ]; then
  sudo chmod 666 /tmp/remote-wsl-loc.txt
fi

# Create the file with proper permissions if it doesn't exist
if [ ! -f /tmp/remote-wsl-loc.txt ]; then
  touch /tmp/remote-wsl-loc.txt
  chmod 666 /tmp/remote-wsl-loc.txt
fi

echo "VS Code permissions fixed. You can now launch VS Code from WSL."
