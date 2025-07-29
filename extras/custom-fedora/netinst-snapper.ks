#version=DEVEL
lang en_US.UTF-8
keyboard us
timezone UTC --utc
selinux --enforcing
firewall --enabled
network --bootproto=dhcp --device=link --activate
rootpw --plaintext changeme
reboot

# Package selection
%packages
@^sway-desktop-environment
git-core
trash-cli
tree
tar
unzip
gawk
zsh
tmux
micro
just
ShellCheck
shfmt
htop
gh
fzf
ripgrep
fd-find
bat
jq
tealdeer
zoxide
git-delta
direnv
libvirt
virt-install
bridge-utils
virglrenderer
qemu
qemu-kvm
qemu-img
qemu-system-x86_64
qemu-device-display-virtio-vga
qemu-device-display-virtio-gpu
cockpit
cockpit-machines
cockpit
%end
