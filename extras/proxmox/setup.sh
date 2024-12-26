#!/bin/bash

set -e

{

# https://community-scripts.github.io/ProxmoxVE/scripts?id=post-pve-install
proxmox_init_install() {
    bash -c "$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/misc/post-pve-install.sh)"
}

proxmox_update_templates() {
    pveam update
}

proxmox_download_templates() {
    ubuntu_latest_tmpl=$(pveam available | grep ubuntu | sort -r | head -n 1 | awk '{print $2}')
    pveam download local $ubuntu_latest_tmpl

    debian_latest_tmpl=$(pveam available | grep 'debian-12-standard' | sort -r | head -n 1 | awk '{print $2}')
    pveam download local $debian_latest_tmpl

    rocky_latest_tmpl=$(pveam available | grep rockylinux | sort -r | head -n 1 | awk '{print $2}')
    pveam download local $rocky_latest_tmpl

    fedora_latest_tmpl=$(pveam available | grep fedora | sort -r | head -n 1 | awk '{print $2}')
    pveam download local $fedora_latest_tmpl

    arch_latest_tmpl=$(pveam available | grep archlinux | sort -r | head -n 1 | awk '{print $2}')
    pveam download local $arch_latest_tmpl

    centos_latest_tmpl=$(pveam available | grep centos | sort -r | head -n 1 | awk '{print $2}')
    pveam download local $centos_latest_tmpl
}

proxmox_cloud_init_vms_install() {
    apt update && apt upgrade -y
    apt install git-core
    sclone https://github.com/pervezfunctor/dotfiles.git .dotfiles
    pushd .dotfiles/extras/proxmox
    ./debian-vm-template.sh
    # clone vm from template debian-template
    qm clone 9100 101 --name debian-vm

    ./ubuntu-vm-template.sh
    qm clone 9400 104 --name ubuntu-vm

    ./rocky-vm-template.sh
    qm clone 9300 103 --name rocky-vm

    ./fedora-vm-template.sh
    qm clone 9200 102 --name fedora-vm
    popd
}

}
