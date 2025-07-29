%post --log=/root/ks-post.log

# Enable RPM Fusion (free + nonfree)
dnf install -y \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Add NVIDIA driver (for supported cards)
dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda
# Optional: for Secure Boot systems
# mokutil --disable-validation  # or enable MOK enrollment

# Enable Docker repository
dnf install -y dnf-plugins-core
dnf config-manager --add-repo=https://download.docker.com/linux/fedora/docker-ce.repo
dnf install -y docker-ce docker-ce-cli containerd.io

# Enable and start Docker service
systemctl enable docker
usermod -aG docker pervez  # Replace 'pervez' with your Kickstart user

# Add VSCode repo (Microsoft official)
rpm --import https://packages.microsoft.com/keys/microsoft.asc
cat <<EOF > /etc/yum.repos.d/vscode.repo
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

dnf install -y code

%end
