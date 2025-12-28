#!/bin/bash
set -e

# Timezone and Locale
echo "Setting timezone and locale..."
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
hwclock --systohc
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >/etc/locale.conf

# Hostname configuration
echo "$HOSTNAME" >/etc/hostname
cat >/etc/hosts <<EOL
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
EOL

# Root password
echo "root:$PASSWORD" | chpasswd

# User configuration
echo "Creating user: $USERNAME"
useradd -m -G wheel,storage,power,network,video,audio,optical -s /bin/bash "$USERNAME"
echo "$USERNAME:$PASSWORD" | chpasswd
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Enable services
echo "Enabling services..."
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable sshd

# Btrfs maintenance
echo "Configuring Btrfs maintenance..."
systemctl enable btrfs-scrub@-.timer
systemctl enable btrfs-scrub@home.timer
systemctl enable btrfs-scrub@-.timer

# Create pacman hook for automatic mirror updates
mkdir -p /etc/pacman.d/hooks
cat >/etc/pacman.d/hooks/mirrorupgrade.hook <<EOL
[Trigger]
Operation = Upgrade
Type = Package
Target = pacman-mirrorlist

[Action]
Description = Updating pacman-mirrorlist with reflector...
When = PostTransaction
Exec = /usr/bin/reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
EOL

# GRUB installation
echo "Installing GRUB..."
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --recheck

# Generate GRUB configuration
echo "Generating GRUB configuration..."
grub-mkconfig -o /boot/grub/grub.cfg

# Create user directories
echo "Creating user directories..."
su - "$USERNAME" -c "xdg-user-dirs-update"

# Enable parallel downloads in pacman
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf

# Enable color in pacman
sed -i 's/^#Color/Color/' /etc/pacman.conf

echo "System configuration completed successfully"
