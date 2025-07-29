#version=DEVEL
lang en_US.UTF-8
keyboard us
timezone Asia/Kolkata --utc
rootpw --plaintext changeme123
user --name=pervez --groups=wheel --plaintext --password=changeme123
network --bootproto=dhcp --device=link --activate
authselect select sssd --force
firewall --enabled --service=ssh
selinux --enforcing
firstboot --enable
services --enabled=NetworkManager,sshd

# Don’t wipe any disks
#clearpart --all --initlabel

bootloader --timeout=5 --location=mbr

%packages
@^workstation-product-environment
btrfs-progs
snapper
snapper-plugins
grub-btrfs
inotify-tools
vim
zsh
anaconda
anaconda-install-env-deps
%end

%post --log=/root/post.log

# Optional: Create btrfs subvolumes and enable Snapper only after install
echo "Post-install script runs in Live session"
%end
