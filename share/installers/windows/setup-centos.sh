#!/usr/bin/env bash

# Get username and password from arguments
username="$1"
password="$2"

if [ -z "$username" ] || [ -z "$password" ]; then
    echo "Error: Username and password must be provided"
    exit 1
fi

# Create the user
useradd -m -G wheel "$username" 2>/dev/null || echo "User $username already exists"

# Set password for the user non-interactively
echo "$username:$password" | chpasswd

# Configure sudo access
echo '%wheel ALL=(ALL) ALL' > /etc/sudoers.d/wheel
chmod 440 /etc/sudoers.d/wheel

# Set as default WSL user and enable systemd
echo -e '[user]\ndefault='"$username"'\n\n[boot]\nsystemd=true' > /etc/wsl.conf

# Install SSH server
echo "Installing SSH server..."
dnf install -y openssh-server

# Configure SSH to allow password authentication
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Check if systemd is available as PID 1
if [[ $(ps -p 1 -o comm=) == "systemd" ]]; then
    # Enable and start SSH service with systemd
    systemctl enable sshd
    systemctl start sshd
    echo "SSH service enabled and started with systemd"
else
    # Start SSH without systemd
    /usr/sbin/sshd

    # Add SSH startup to bashrc to ensure it starts on login
    if ! grep -q "pgrep sshd" /etc/bashrc; then
        echo '[[ ! $(pgrep sshd) ]] && sudo /usr/sbin/sshd' >> /etc/bashrc
        echo "Added SSH startup command to system bashrc"
    fi
    echo "Started SSH service directly (systemd not available)"
fi

# Create SSH directory for the new user
mkdir -p "/home/$username/.ssh"
chmod 700 "/home/$username/.ssh"
chown -R "$username:$username" "/home/$username/.ssh"

# Display IP address for connection
echo "Setup complete!"
echo "You can connect to this instance via SSH:"
echo " ssh $username@$(hostname -I)"
