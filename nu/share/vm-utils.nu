#!/usr/bin/env nu

use utils.nu

export const DISTRO_LIST_VME = ["ubuntu", "fedora", "arch", "debian", "tw"]
export const DISTRO_LIST_VM = ["ubuntu", "fedora", "debian", "arch", "alpine", "centos"]

# Check that all required commands are present
export def vm-check-cmds [...cmds: string]: nothing -> nothing {
    for cmd in $cmds {
        if not (has-cmd $cmd) {
            fail $"Required command not found: ($cmd)"
            return
        }
    }
}

# Check prerequisites for libvirt VM management
export def virt-check-prerequisites []: nothing -> nothing {
    if (has-cmd osquery-update-db) {
        do { ^osquery-update-db } | ignore
    }

    vm-check-cmds virsh virt-install qemu-img wget xorriso openssl vm-create vm

    let active = (do { ^systemctl is-active --quiet libvirtd } | complete)
    if $active.exit_code != 0 {
        warn "libvirtd service is not running, Starting..."
        ^sudo systemctl start libvirtd
        sleep 1sec

        let active2 = (do { ^systemctl is-active --quiet libvirtd } | complete)
        if $active2.exit_code != 0 {
            fail "Failed to start libvirtd service"
            return
        }
        slog "libvirtd service started"
    }

    let groups_out = (^groups)
    if not ($groups_out | str contains "libvirt") {
        fail "User not in libvirt group. You may need sudo for virsh commands"
        fail $"Add user to group: sudo usermod -a -G libvirt ($env.USER)"
        return
    }
}

# Return a list of all defined VM names
export def get-vm-list []: nothing -> list<string> {
    ^virsh --connect qemu:///system list --all
        | lines
        | skip 2
        | where { |l| ($l | split words | length) >= 2 }
        | each { |l| $l | split words | get 1 }
}

# List all VMs with virsh
export def vm-list []: nothing -> nothing {
    slog "Listing all VMs..."
    print ""
    if (has-cmd virsh) {
        ^virsh list --all
    } else {
        fail "virsh command not found. Please install virtualization tools first."
    }
}

# Return true if a VM exists
export def vm-exists [vm_name: string]: nothing -> bool {
    let result = (do { ^virsh dominfo $vm_name } | complete)
    $result.exit_code == 0
}

# Alias for vm-exists (VME variant)
export def vme-exists [vm_name: string]: nothing -> bool {
    vm-exists $vm_name
}

# Fail if VM does not exist
export def vm-check-exists [vm_name: string]: nothing -> nothing {
    if not (vm-exists $vm_name) {
        fail $"VM '($vm_name)' not found"
    }
}

# Return the current state string of a VM
export def vm-state [vm_name: string]: nothing -> string {
    ^virsh domstate $vm_name | str trim
}

# Return true if a VM is running
export def vm-running [vm_name: string]: nothing -> bool {
    if not (vm-exists $vm_name) { return false }
    (vm-state $vm_name) == "running"
}

# Alias for vm-running (VME variant)
export def vme-running [vm_name: string]: nothing -> bool {
    vm-running $vm_name
}

# Fail if VM is not running
export def vm-check-running [vm_name: string]: nothing -> nothing {
    vm-check-exists $vm_name
    if not (vm-running $vm_name) {
        fail $"VM '($vm_name)' is not running"
    }
}

# Get the IP address of a running VM via the guest agent, or empty string on failure
export def vm-ip [vm_name: string]: nothing -> string {
    let result = (do {
        ^virsh --connect qemu:///system domifaddr --source agent $vm_name
    } | complete)
    if $result.exit_code != 0 { return "" }

    $result.stdout
        | lines
        | where { |l| ($l | str contains "ipv4") }
        | where { |l| not (($l | split words | first? | default "") == "lo") }
        | first?
        | default ""
        | split words
        | get 3?
        | default ""
        | split row "/"
        | first?
        | default ""
}

# Alias for vm-ip (VME variant)
export def vme-ip [vm_name: string]: nothing -> string {
    vm-ip $vm_name
}

# SSH into a running VM
export def vm-ssh [vm_name: string, username: string]: nothing -> nothing {
    vm-check-exists $vm_name

    let state = (vm-state $vm_name)
    if $state != "running" {
        fail $"VM '($vm_name)' is not running"
        slog $"Start it with: vm start ($vm_name)"
        return
    }

    let ip = (vm-ip $vm_name)
    if ($ip | is-empty) {
        fail $"Could not determine IP address for VM '($vm_name)'"
        return
    }

    slog $"Connecting to ($vm_name) (($ip)) as ($username)..."
    exec ssh $"($username)@($ip)"
}

# Return true if a libvirt network is defined
export def libvirt-net-defined [net_name: string]: nothing -> bool {
    let result = (do { ^virsh net-info $net_name } | complete)
    $result.exit_code == 0
}

# Return true if the default libvirt network is defined
export def libvirt-default-net-defined []: nothing -> bool {
    libvirt-net-defined "default"
}

# Define a libvirt network, searching well-known XML locations
export def define-default-net [net_name: string = "default"]: nothing -> nothing {
    if (libvirt-net-defined $net_name) {
        print $"Network '($net_name)' is already defined."
        return
    }

    print $"Network '($net_name)' is not defined. Attempting to define it..."

    let candidates = [
        "/usr/share/libvirt/networks/default.xml"
        "/usr/local/share/libvirt/networks/default.xml"
        "/var/lib/libvirt/network/default.xml"
        "/etc/libvirt/qemu/networks/default.xml"
    ]

    let found = ($candidates | where { |f| $f | path exists } | first?)
    if ($found | is-not-empty) {
        print $"Found default network XML at ($found)"
        ^virsh net-define $found
        return
    }

    print "Dumping default network XML to /tmp/default.xml to define it..."
    ^rm -f /tmp/default.xml
    ^virsh net-dumpxml default | save -f /tmp/default.xml
    ^virsh net-define /tmp/default.xml
}

# Destroy and undefine a libvirt network
export def undefine-default-net [net_name: string = "default"]: nothing -> nothing {
    if (libvirt-net-defined $net_name) {
        print $"Network '($net_name)' is defined. Attempting to undefine it..."
        ^virsh net-destroy $net_name
        ^virsh net-undefine $net_name
    } else {
        print $"Network '($net_name)' is not defined."
    }
}

# Ensure a libvirt network is defined, active, and set to autostart
export def ensure-libvirt-default-net [net_name: string = "default"]: nothing -> nothing {
    define-default-net $net_name

    let state = (^virsh net-info $net_name
        | lines
        | where { |l| $l | str contains "State:" }
        | first?
        | default ""
        | split words
        | get 1?
        | default "")
    if $state != "active" {
        print $"Starting network '($net_name)'..."
        ^virsh net-start $net_name
    } else {
        print $"Network '($net_name)' is already running."
    }

    let autostart = (^virsh net-info $net_name
        | lines
        | where { |l| $l | str contains "Autostart:" }
        | first?
        | default ""
        | split words
        | get 1?
        | default "")
    if $autostart != "yes" {
        print $"Enabling autostart for '($net_name)'..."
        ^virsh net-autostart $net_name
    }
}

export const LIBVIRT_ISO_POOL_PATH = "/srv/libvirt/images/iso"
export const LIBVIRT_ISO_POOL_NAME = "iso-pool"

# Create the libvirt ISO storage pool if it does not already exist
export def libvirt-iso-pool-create []: nothing -> nothing {
    let result = (do { ^virsh pool-info $LIBVIRT_ISO_POOL_NAME } | complete)
    if $result.exit_code == 0 { return }

    print $"Creating ISO pool ($LIBVIRT_ISO_POOL_NAME) at ($LIBVIRT_ISO_POOL_PATH)..."
    ^sudo mkdir -p $LIBVIRT_ISO_POOL_PATH
    ^sudo virsh pool-define-as $LIBVIRT_ISO_POOL_NAME dir --target $LIBVIRT_ISO_POOL_PATH
    ^sudo virsh pool-start $LIBVIRT_ISO_POOL_NAME
    ^sudo virsh pool-autostart $LIBVIRT_ISO_POOL_NAME
}

# Return Arch Linux cloud image configuration
export def configure-arch []: nothing -> record<release: string, img_url: string, checksum_url: string, os_variant: string> {
    {
        release: "latest"
        img_url: "https://geo.mirror.pkgbuild.com/images/latest/Arch-Linux-x86_64-cloudimg.qcow2"
        checksum_url: "https://geo.mirror.pkgbuild.com/images/latest/Arch-Linux-x86_64-cloudimg.qcow2.SHA256"
        os_variant: "archlinux"
    }
}

# Return Ubuntu cloud image configuration
export def configure-ubuntu [release: string = ""]: nothing -> record<release: string, img_url: string, checksum_url: string, os_variant: string> {
    let r = (if ($release | is-not-empty) { $release } else { "questing" })
    {
        release: $r
        img_url: $"https://cloud-images.ubuntu.com/($r)/current/($r)-server-cloudimg-amd64.img"
        checksum_url: $"https://cloud-images.ubuntu.com/($r)/current/SHA256SUMS"
        os_variant: "ubuntu25.10"
    }
}

# Return Debian cloud image configuration
export def configure-debian [release: string = ""]: nothing -> record<release: string, img_url: string, checksum_url: string, os_variant: string> {
    let r = (if ($release | is-not-empty) { $release } else { "trixie" })
    {
        release: $r
        img_url: "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-generic-amd64.qcow2"
        checksum_url: "https://cloud.debian.org/images/cloud/trixie/latest/SHA512SUMS"
        os_variant: "debian13"
    }
}

# Return Fedora cloud image configuration
export def configure-fedora [release: string = ""]: nothing -> record<release: string, img_url: string, checksum_url: string, os_variant: string> {
    let r = "43"
    {
        release: $r
        img_url: $"https://download.fedoraproject.org/pub/fedora/linux/releases/($r)/Cloud/x86_64/images/Fedora-Cloud-Base-Generic-43-1.6.x86_64.qcow2"
        checksum_url: $"https://mirror.hoster.kz/fedora/fedora/linux/releases/($r)/Cloud/x86_64/images/Fedora-Cloud-43-1.6-x86_64-CHECKSUM"
        os_variant: "fedora42"
    }
}

# Return openSUSE Tumbleweed cloud image configuration
export def configure-tw []: nothing -> record<release: string, img_url: string, checksum_url: string, os_variant: string> {
    {
        release: "latest"
        img_url: "https://download.opensuse.org/tumbleweed/appliances/openSUSE-Tumbleweed-Minimal-VM.x86_64-Cloud.qcow2"
        checksum_url: "https://download.opensuse.org/tumbleweed/appliances/openSUSE-Tumbleweed-Minimal-VM.x86_64-Cloud.qcow2.sha256"
        os_variant: "opensusetumbleweed"
    }
}

# Return CentOS Stream cloud image configuration
export def configure-centos [release: string = ""]: nothing -> record<release: string, img_url: string, checksum_url: string, os_variant: string> {
    let r = (if ($release | is-not-empty) { $release } else { "9" })
    {
        release: $r
        img_url: $"https://cloud.centos.org/centos/($r)-stream/x86_64/images/CentOS-Stream-GenericCloud-($r)-latest.x86_64.qcow2"
        checksum_url: $"https://cloud.centos.org/centos/($r)-stream/x86_64/images/CentOS-Stream-GenericCloud-($r)-latest.x86_64.qcow2.SHA256SUM"
        os_variant: "centos-stream9"
    }
}

# Return Rocky Linux cloud image configuration
export def configure-rocky [release: string = ""]: nothing -> record<release: string, img_url: string, checksum_url: string, os_variant: string> {
    let r = (if ($release | is-not-empty) { $release } else { "9" })
    {
        release: $r
        img_url: $"https://download.rockylinux.org/pub/rocky/($r)/images/x86_64/Rocky-($r)-GenericCloud.latest.x86_64.qcow2"
        checksum_url: $"https://download.rockylinux.org/pub/rocky/($r)/images/x86_64/CHECKSUM"
        os_variant: "rocky-linux-9"
    }
}

# Return Alpine Linux cloud image configuration
export def configure-alpine [release: string = ""]: nothing -> record<release: string, img_url: string, checksum_url: string, os_variant: string> {
    let r = (if ($release | is-not-empty) { $release } else { "3.22.2" })
    {
        release: $r
        img_url: $"https://dl-cdn.alpinelinux.org/alpine/v($r)/releases/cloud/generic_alpine-($r)-x86_64-uefi-cloudinit-r0.qcow2"
        checksum_url: $"https://dl-cdn.alpinelinux.org/alpine/($r)/releases/cloud/generic_alpine-($r)-x86_64-uefi-cloudinit-r0.qcow2.sha512"
        os_variant: "alpinelinux3.22"
    }
}

# Return the full distribution config including base_image and checksum_file paths
export def configure-distribution [
    distro: string
    base_img_dir: string
    release: string = ""
]: nothing -> record {
    let d = ($distro | str downcase)
    let cfg = (match $d {
        "arch" => (configure-arch)
        "ubuntu" => (configure-ubuntu $release)
        "debian" => (configure-debian $release)
        "fedora" => (configure-fedora $release)
        "tw" | "tumbleweed" => (configure-tw)
        "centos" => (configure-centos $release)
        "rocky" => (configure-rocky $release)
        "alpine" => (configure-alpine $release)
        _ => {
            error make {msg: $"Unknown distribution: ($distro). Supported: arch, ubuntu, debian, fedora, tumbleweed, centos, rocky, alpine"}
        }
    })

    let base_image = ($base_img_dir | path join ($cfg.img_url | path basename))
    let checksum_file = $"($base_image).checksum"

    $cfg | merge {base_image: $base_image, checksum_file: $checksum_file}
}

# Generate cloud-init user-data and meta-data files for a VM
# Returns a record with the paths: {user_data: string, meta_data: string}
export def generate-cloud-init [
    vm_name: string
    username: string
    password: string
    ssh_key_path: string
    distro: string
]: nothing -> record<user_data: string, meta_data: string> {
    slog "Generating cloud-init configuration..."

    let password_hash = (^openssl passwd -6 $password | str trim)
    let cloud_init_dir = (^mktemp -d | str trim)
    let user_data = ($cloud_init_dir | path join "user-data")
    let meta_data = ($cloud_init_dir | path join "meta-data")

    let pub_key = (open $ssh_key_path | str trim)

    let openssh_pkg = if (($distro == "arch") or ($distro == "tw") or ($distro == "tumbleweed")) {
        "openssh"
    } else {
        "openssh-server"
    }

    let packages = ["qemu-guest-agent", "bash", "curl", $openssh_pkg]

    let runcmd_lines = if $distro == "alpine" {
        [
            "rc-update add qemu-guest-agent default || true"
            "service qemu-guest-agent start || true"
            "rc-update add sshd default || true"
            "service sshd start || true"
        ]
    } else {
        [
            "systemctl enable --now qemu-guest-agent || true"
            "systemctl enable --now ssh || systemctl enable --now sshd || true"
        ]
    }

    let sudo_groups = if (($distro == "ubuntu") or ($distro == "debian")) { "sudo" } else { "wheel" }

    let packages_yaml = ($packages | each { |p| $"  - ($p)" } | str join "\n")
    let runcmd_yaml = ($runcmd_lines | each { |l| $"  - ($l)" } | str join "\n")

    let user_data_content = $"#cloud-config
hostname: ($vm_name)
manage_etc_hosts: true

users:
  - name: ($username)
    groups:
      - ($sudo_groups)
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    lock_passwd: false
    passwd: ($password_hash)
    ssh_authorized_keys:
      - ($pub_key)

package_update: true

packages:
($packages_yaml)

runcmd:
($runcmd_yaml)
"

    $user_data_content | save -f $user_data

    let timestamp = (^date +%s | str trim)
    $"instance-id: ($vm_name)-($timestamp)\nlocal-hostname: ($vm_name)\n" | save -f $meta_data

    success "Cloud-init configuration generated"
    {user_data: $user_data, meta_data: $meta_data}
}

# Verify a checksum file against a downloaded image, dying on mismatch
export def verify-checksum [img: string, sumfile: string]: nothing -> nothing {
    let base_img = ($img | path basename)
    info $"Verifying checksum for: ($base_img)"

    # Strip PGP signature lines in place
    let cleaned_lines = (open $sumfile
        | lines
        | where { |l|
            (not ($l | str starts-with "-----BEGIN")) and (not ($l | str starts-with "-----END"))
        })
    $cleaned_lines | str join "\n" | save -f $sumfile

    let content_lines = ($cleaned_lines | where { |l| not ($l | str trim | is-empty) })

    # 1. Fedora/CentOS style: SHA256 (filename) = hash
    let fedora_lines = ($content_lines | where { |l| $l | str contains $"SHA256 \(($base_img)\) =" })
    let hash = if ($fedora_lines | is-not-empty) {
        $fedora_lines | first | split column " = " | get column2 | first | str trim
    } else {
        # 2. GNU style: <hash>  filename  or  <hash> *filename
        let gnu_lines = ($content_lines | where { |l|
            ($l | str ends-with $base_img) or ($l | str ends-with $" *($base_img)")
        })
        if ($gnu_lines | is-not-empty) {
            $gnu_lines | first | split words | first
        } else if ($content_lines | length) == 1 {
            # 3. Raw Alpine-style: single-line single-word hash
            let words = ($content_lines | first | split words)
            if ($words | length) == 1 { $words | first } else { "" }
        } else {
            ""
        }
    }

    if ($hash | is-empty) {
        fail $"Unsupported checksum format for ($base_img)"
        sleep 2sec
        warn "Skipping checksum verification..."
        return
    }

    let hash_len = ($hash | str length)
    if $hash_len == 64 {
        let result = (do { $"($hash)  ($img)" | ^sha256sum -c - } | complete)
        if $result.exit_code != 0 { fail "SHA256 checksum mismatch" }
    } else if $hash_len == 128 {
        let result = (do { $"($hash)  ($img)" | ^sha512sum -c - } | complete)
        if $result.exit_code != 0 { fail "SHA512 checksum mismatch" }
    } else {
        fail $"Unknown checksum length ($hash_len)"
        return
    }

    info "Checksum OK"
}
