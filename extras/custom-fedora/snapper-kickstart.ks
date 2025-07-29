#version=DEVEL
# System authorization information
auth --enableshadow --passalgo=sha512

# Use CDROM installation media
cdrom

# Use text install
text

# Run the Setup Agent on first boot
firstboot --enable

# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'

# System language
lang en_US.UTF-8

# Network information
network --bootproto=dhcp --device=link --activate

# Root password (change this!)
rootpw --lock
user --groups=wheel --name=fedora --password=$6$salt$encrypted_password --iscrypted --gecos="Fedora User"

# System services
services --enabled="chronyd,snapper-timeline.timer,snapper-cleanup.timer"

# System timezone
timezone America/New_York --isUtc

# System bootloader configuration
bootloader --location=mbr --boot-drive=sda --append="rd.luks.uuid=luks-root"

# Partition clearing information
clearpart --all --initlabel

# Disk partitioning information
part /boot/efi --fstype="efi" --ondisk=sda --size=512 --fsoptions="umask=0077,shortname=winnt"
part /boot --fstype="ext4" --ondisk=sda --size=1024
part pv.01 --fstype="lvmpv" --ondisk=sda --size=1 --grow --encrypted --passphrase=changeme

# LVM configuration
volgroup fedora --pesize=4096 pv.01
logvol / --fstype="btrfs" --size=1 --grow --name=root --vgname=fedora --fsoptions="compress=zstd:1,space_cache=v2,autodefrag"

# Btrfs subvolume configuration
%post --nochroot
# Create Btrfs subvolumes optimized for Snapper
mkdir -p /mnt/sysimage
mount /dev/mapper/fedora-root /mnt/sysimage

# Create subvolumes
btrfs subvolume create /mnt/sysimage/@
btrfs subvolume create /mnt/sysimage/@home
btrfs subvolume create /mnt/sysimage/@snapshots
btrfs subvolume create /mnt/sysimage/@var_log
btrfs subvolume create /mnt/sysimage/@var_cache
btrfs subvolume create /mnt/sysimage/@var_tmp
btrfs subvolume create /mnt/sysimage/@tmp

# Set default subvolume
btrfs subvolume set-default $(btrfs subvolume list /mnt/sysimage | grep "@$" | awk '{print $2}') /mnt/sysimage

umount /mnt/sysimage
%end

# Package selection
%packages
@^minimal-environment
@development-tools
kernel-devel
kernel-headers
dkms
btrfs-progs
snapper
python3-dnf-plugin-snapper
grub-btrfs
vim
nano
wget
curl
git
htop
tree
%end

# Post-installation script
%post
# Configure Snapper
snapper -c root create-config /
snapper -c home create-config /home

# Configure Snapper settings for root
cat >/etc/snapper/configs/root <<'EOF'
SUBVOLUME="/"
FSTYPE="btrfs"
QGROUP=""
SPACE_LIMIT="0.5"
FREE_LIMIT="0.2"
ALLOW_USERS=""
ALLOW_GROUPS=""
SYNC_ACL="no"
BACKGROUND_COMPARISON="yes"
NUMBER_CLEANUP="yes"
NUMBER_MIN_AGE="1800"
NUMBER_LIMIT="50"
NUMBER_LIMIT_IMPORTANT="10"
TIMELINE_CREATE="yes"
TIMELINE_CLEANUP="yes"
TIMELINE_MIN_AGE="1800"
TIMELINE_LIMIT_HOURLY="10"
TIMELINE_LIMIT_DAILY="10"
TIMELINE_LIMIT_WEEKLY="0"
TIMELINE_LIMIT_MONTHLY="10"
TIMELINE_LIMIT_YEARLY="10"
EMPTY_PRE_POST_CLEANUP="yes"
EMPTY_PRE_POST_MIN_AGE="1800"
EOF

# Configure Snapper settings for home
cat >/etc/snapper/configs/home <<'EOF'
SUBVOLUME="/home"
FSTYPE="btrfs"
QGROUP=""
SPACE_LIMIT="0.5"
FREE_LIMIT="0.2"
ALLOW_USERS=""
ALLOW_GROUPS=""
SYNC_ACL="no"
BACKGROUND_COMPARISON="yes"
NUMBER_CLEANUP="yes"
NUMBER_MIN_AGE="1800"
NUMBER_LIMIT="30"
NUMBER_LIMIT_IMPORTANT="5"
TIMELINE_CREATE="yes"
TIMELINE_CLEANUP="yes"
TIMELINE_MIN_AGE="1800"
TIMELINE_LIMIT_HOURLY="5"
TIMELINE_LIMIT_DAILY="7"
TIMELINE_LIMIT_WEEKLY="0"
TIMELINE_LIMIT_MONTHLY="5"
TIMELINE_LIMIT_YEARLY="5"
EMPTY_PRE_POST_CLEANUP="yes"
EMPTY_PRE_POST_MIN_AGE="1800"
EOF

# Update fstab for proper subvolume mounting
cat >/etc/fstab <<'EOF'
/dev/mapper/fedora-root / btrfs subvol=@,compress=zstd:1,space_cache=v2,autodefrag 0 0
/dev/mapper/fedora-root /home btrfs subvol=@home,compress=zstd:1,space_cache=v2,autodefrag 0 0
/dev/mapper/fedora-root /.snapshots btrfs subvol=@snapshots,compress=zstd:1,space_cache=v2 0 0
/dev/mapper/fedora-root /var/log btrfs subvol=@var_log,compress=zstd:1,space_cache=v2 0 0
/dev/mapper/fedora-root /var/cache btrfs subvol=@var_cache,compress=zstd:1,space_cache=v2 0 0
/dev/mapper/fedora-root /var/tmp btrfs subvol=@var_tmp,compress=zstd:1,space_cache=v2 0 0
/dev/mapper/fedora-root /tmp btrfs subvol=@tmp,compress=zstd:1,space_cache=v2 0 0
EOF

# Add boot and EFI entries (these will be handled by the installer)

# Enable services
systemctl enable snapper-timeline.timer
systemctl enable snapper-cleanup.timer
systemctl enable chronyd

# Configure DNF for Snapper integration
echo "snapper_create_snapshots=True" >>/etc/dnf/dnf.conf

# Create initial snapshot
snapper -c root create --description "Initial installation snapshot"
snapper -c home create --description "Initial home snapshot"

# Configure GRUB for Btrfs snapshots
echo 'GRUB_BTRFS_LIMIT="10"' >>/etc/default/grub
echo 'GRUB_BTRFS_SHOW_SNAPSHOTS_FOUND="true"' >>/etc/default/grub

# Rebuild GRUB configuration
grub2-mkconfig -o /boot/grub2/grub.cfg

# Set proper permissions
chmod 750 /.snapshots
chmod 750 /home/.snapshots

echo "Btrfs with Snapper configuration completed successfully!"
%end

# Reboot after installation
reboot
