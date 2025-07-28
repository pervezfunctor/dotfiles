#version=42

# check syntax of this file with ksvalidator

lang en_US.UTF-8
keyboard us
timezone Asia/Kolkata
network --bootproto=dhcp --device=link --activate

rootpw --plaintext changeme123
# rootpw --iscrypted <hashed-password>

authselect select sssd --force
selinux --enforcing
firewall --enabled --service=ssh
services --enabled=NetworkManager,sshd
firstboot --disable

# Bootloader setup
bootloader --location=mbr --timeout=5

# User account
user --name=pervez --groups=wheel --plaintext --password=changeme123
# user --name=pervez --iscrypted --password=<hashed-password>

# No autopart or clearpart — manual partitioning assumed

%packages
@^workstation-product-environment
btrfs-progs
snapper
snapper-plugins
grub2
grub2-tools
grub2-efi-x64
grub-btrfs
inotify-tools
dnf-plugins-core
vim
zsh
%end

%post --log=/root/ks-post.log
set -euo pipefail

echo ">>> Creating Btrfs subvolumes..."

# 🟡 WARNING: Adjust this to match your disk/partition
disk="/dev/sda3"
mountpoint="/mnt"

mkfs.btrfs -f -L FEDORA "${disk}"
mount "${disk}" "${mountpoint}"

btrfs subvolume create ${mountpoint}/@
btrfs subvolume create ${mountpoint}/@home
btrfs subvolume create ${mountpoint}/@boot
btrfs subvolume create ${mountpoint}/@.snapshots

umount "${mountpoint}"

echo ">>> Generating /etc/fstab..."
uuid=$(blkid -s UUID -o value "${disk}")
cat > /etc/fstab <<EOF
UUID=${uuid} /              btrfs subvol=@          0 0
UUID=${uuid} /home          btrfs subvol=@home      0 0
UUID=${uuid} /boot          btrfs subvol=@boot      0 0
UUID=${uuid} /.snapshots    btrfs subvol=@.snapshots 0 0
EOF

mkdir -p /.snapshots
chmod 750 /.snapshots
mount --bind /.snapshots /.snapshots
echo "/.snapshots /.snapshots none bind 0 0" >> /etc/fstab

echo ">>> Configuring Snapper..."
snapper -c root create-config /
chmod 750 /.snapshots

echo ">>> Enabling grub-btrfs integration..."
systemctl enable grub-btrfs.path
%end

echo ">>> Setting up systemd post-boot service..."

cat > /etc/systemd/system/setup-home.service << 'EOF'
[Unit]
Description=First-boot user setup
After=default.target
ConditionPathExists=!/etc/setup-home-done

[Service]
Type=oneshot
ExecStart=/usr/local/bin/setup-home.sh
RemainAfterExit=yes

[Install]
WantedBy=default.target
EOF

cat > /usr/local/bin/setup-home.sh << 'EOF'
#!/bin/bash
set -euo pipefail

echo ">>> Customizing user home for 'pervez'..."

USER=pervez
USER_HOME="/home/$USER"

# Example setup
mkdir -p "$USER_HOME/.config"
touch "$USER_HOME/.config/example"
chown -R "$USER:$USER" "$USER_HOME/.config"

# Set up marker so it never runs again
touch /etc/setup-home-done
EOF

chmod +x /usr/local/bin/setup-home.sh

# Enable the service
systemctl enable setup-home.service

# curl -sSL https://is.gd/egitif -o /tmp/myscript.sh
# echo "<SHA256SUM>  /tmp/myscript.sh" | sha256sum -c -
# bash /tmp/myscript.sh -- shell-slim

%end
%addon com_redhat_kdump --disable
%end
