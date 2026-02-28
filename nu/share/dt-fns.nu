#! /usr/bin/env nu

use utils.nu

export-env {
    $env.BOXES_DIR = ($env.USE_BOXES_DIR? | default ($env.HOME | path join ".boxes"))
}

# ============================================
# Podman/Distrobox Logs
# ============================================

export def dt-logs [container: string]: nothing -> nothing {
    podman logs $container
}

# ============================================
# Distrobox Enter
# ============================================

export def dt-enter [
    container_name: string
    ...args: string
]: nothing -> nothing {
    distrobox enter -nw --clean-path --name $container_name -- ...$args
}

export def dt-enter-root [
    container_name: string
    ...args: string
]: nothing -> nothing {
    distrobox enter -nw --clean-path --root --name $container_name -- ...$args
}

export def dt-exec [
    container_name: string
    ...args: string
]: nothing -> nothing {
    dt-enter $container_name ...$args
}

export def dt-exec-root [
    container_name: string
    ...args: string
]: nothing -> nothing {
    dt-enter-root $container_name ...$args
}

export def dt-bash-exec [
    container_name: string
    ...args: string
]: nothing -> nothing {
    let cmd = ($args | str join " ")
    ^distrobox enter -nw --clean-path --name $container_name -- bash -c $cmd
}

# ============================================
# Distrobox Create
# ============================================

export def dt-create [
    container_name: string
    image: string
    ...args: string
]: nothing -> bool {
    let existing = (distrobox list | grep -q $"^($container_name)$")
    if $existing {
        slog $"Distrobox ($container_name) already exists, skipping creation"
        return true
    }

    if (dir-exists ($env.BOXES_DIR | path join $container_name)) {
        fail $"Directory ($env.BOXES_DIR)/($container_name) already exists"
        return false
    }

    slog $"Creating Ubuntu distrobox: ($container_name)"
    let home_dir = ($env.BOXES_DIR | path join $container_name)
    let result = (^distrobox create --hostname $container_name --yes --image $image --home $home_dir --name $container_name ...$args)

    if $result {
        slog $"Distrobox ($container_name) created successfully"
        slog $"Use dte ($container_name) to enter"
        true
    } else {
        fail $"Failed to create distrobox ($container_name)"
        false
    }
}

export def dt-create-root [
    container_name: string
    image: string
    ...args: string
]: nothing -> bool {
    let existing = (distrobox list | grep -q $"^($container_name)$")
    if $existing {
        slog $"Distrobox ($container_name) already exists, skipping creation"
        return true
    }

    if (dir-exists ($env.BOXES_DIR | path join $container_name)) {
        fail $"Directory ($env.BOXES_DIR)/($container_name) already exists"
        return false
    }

    slog $"Creating root distrobox: ($container_name)"
    let home_dir = ($env.BOXES_DIR | path join $container_name)
    let result = (^distrobox create --root --hostname $container_name --yes --image $image --home $home_dir --name $container_name ...$args)

    if $result {
        slog $"Distrobox ($container_name) created successfully"
        slog $"Use rdte ($container_name) to enter"
        true
    } else {
        fail $"Failed to create distrobox ($container_name)"
        false
    }
}

# ============================================
# No-init containers
# ============================================

export def dt-ubuntu-noinit [container_name: string = "ubuntu-noinit"]: nothing -> bool {
    dt-create $container_name ubuntu:questing
}

export def dt-arch-noinit [container_name: string = "arch-noinit"]: nothing -> bool {
    dt-create $container_name archlinux:latest
}

export def dt-fedora-minimal-noinit [
    container_name: string = "fedora-minimal-noinit"
]: nothing -> bool {
    dt-create $container_name registry.fedoraproject.org/fedora-minimal:latest
}

export def dt-debian-slim-noinit [
    container_name: string = "debian-slim-noinit"
]: nothing -> bool {
    dt-create $container_name debian:trixie-slim
}

export def dt-fedora-noinit [container_name: string = "fedora-noinit"]: nothing -> bool {
    dt-create $container_name fedora:latest
}

export def dt-centos-noinit [container_name: string = "centos-noinit"]: nothing -> bool {
    dt-create $container_name centos:latest
}

export def dt-debian-noinit [container_name: string = "debian-noinit"]: nothing -> bool {
    dt-create $container_name debian:latest
}

export def dt-rocky-noinit [container_name: string = "rocky-noinit"]: nothing -> bool {
    dt-create $container_name rockylinux:9
}

export def dt-tw-noinit [container_name: string = "tw-noinit"]: nothing -> bool {
    dt-create $container_name opensuse/tumbleweed
}

export def dt-bluefin [container_name: string = "bluefin-cli"]: nothing -> bool {
    dt-create $container_name ghcr.io/ublue-os/bluefin-cli
}

export def dt-wolfi [container_name: string = "wolfi-ublue"]: nothing -> bool {
    dt-create $container_name ghcr.io/ublue-os/wolfi-toolbox
}

export def dt-virt-manager [container_name: string = "virt-manager"]: nothing -> bool {
    let pkgs = [
        openssh-server patterns-server-kvm_server patterns-server-kvm_tools
        qemu-extra qemu-linux-user qemu-hw-display-virtio-gpu qemu-ui-opengl
        qemu-spice spice-gtk libvirglrenderer1 xmlstarlet jq
    ]

    let services = [
        sshd.service virtqemud.socket virtnetworkd.socket virtstoraged.socket
        virtnodedevd.socket
    ]

    let pkgs_str = ($pkgs | str join " ")
    let services_str = ($services | str join " ")
    let init_hooks = $"zypper in -y --no-recommends ($pkgs_str) && systemctl enable ($services_str) && usermod -aG libvirt $env.USER"
    ^distrobox create --root --hostname $container_name --yes --pull --init --unshare-all --additional-flags "-p 2222:22" --init-hooks $init_hooks
}

export def dt-fedora-virt-manager [
    container_name: string = "fedora-virt-manager"
]: nothing -> bool {
    let pkgs = [openssh-server libvirt virt-install virt-manager]
    let services = [sshd.service virtqemud.socket virtnetworkd.socket virtstoraged.socket virtnodedevd.socket]

    let pkgs_str = ($pkgs | str join " ")
    let services_str = ($services | str join " ")
    let init_hooks = $"dnf install -y --skip-unavailable ($pkgs_str) && systemctl enable ($services_str) && usermod -aG libvirt $env.USER"
    ^distrobox create --root --hostname $container_name --yes --pull --init --unshare-all --additional-flags "-p 2222:22" --init-hooks $init_hooks
}

export def dt-docker-base [
    container_name: string = "docker-base"
]: nothing -> bool {
    let home_dir = ($env.BOXES_DIR | path join $container_name)
    let cmd = $"distrobox create --root --hostname ($container_name) --yes --image fedora:latest --home ($home_dir) --name ($container_name) --additional-packages 'systemd docker' --init --unshare-all"
    nu -c $cmd

    ^distrobox enter -nw --clean-path --root --name $container_name -- sudo systemctl enable --now docker
    ^distrobox enter -nw --clean-path --root --name $container_name -- sudo usermod -aG docker $env.USER
}

export def dt-docker-slim [
    container_name: string = "docker"
]: nothing -> bool {
    slog $"Creating Docker distrobox: ($container_name)"
    sudo mkdir -p /var/lib/docker

    let home_dir = ($env.BOXES_DIR | path join $container_name)
    let cmd = $"distrobox create --root --hostname ($container_name) --yes --image ghcr.io/ublue-os/docker-distrobox:latest --home ($home_dir) --name ($container_name) --init --unshare-all --no-entry --volume /var/lib/docker --additional-packages 'systemd libpam-systemd'"
    nu -c $cmd
}

export def dt-docker [container_name: string = "docker"]: nothing -> bool {
    dt-docker-slim $container_name
}

export def dt-incus [container_name: string = "incus"]: nothing -> bool {
    slog $"Creating Incus distrobox: ($container_name)"
    sudo mkdir -p /var/lib/incus

    let home_dir = ($env.BOXES_DIR | path join $container_name)
    let init_hooks = $"usermod -aG incus-admin ($env.USER)"
    let cmd = $"distrobox create --root --hostname ($container_name) --yes --image ghcr.io/ublue-os/incus-distrobox:latest --home ($home_dir) --name ($container_name) --init --unshare-all --no-entry --volume /var/lib/incus:/var/lib/incus --volume /lib/modules:/lib/modules:ro --additional-packages 'systemd libpam-systemd' --init-hooks '($init_hooks)'"
    nu -c $cmd
}

# ============================================
# ILM Setup Containers
# ============================================

export def dt-create-ilm [
    container_name: string = "ilm"
    image: string = ""
    ...args: string
]: nothing -> bool {
    if ($image | is-empty) {
        fail "Image is required for dt-create-ilm"
        return false
    }
    dt-create $container_name $image ...$args
    let base_url = "https://raw.githubusercontent.com/pervezfunctor/dotfiles/main"
    let setup_url = $env.ILM_SETUP_URL? | default $"($base_url)/share/installers/setup"
    ^distrobox enter -nw --clean-path --name $container_name -- bash -c (curl -sSL $setup_url) -- dt-slim
}

export def dt-alpine-edge [container_name: string = "alpine-edge"]: nothing -> bool {
    dt-create-ilm $container_name quay.io/toolbx-images/alpine-toolbox:edge "--init" "--additional-packages" "openrc openssh-server"
    ^distrobox enter -nw --clean-path --name $container_name -- sudo rc-update add sshd default
}

export def dt-alpine [container_name: string = "alpine"]: nothing -> bool {
    dt-create-ilm $container_name quay.io/toolbx-images/alpine-toolbox:latest "--init" "--additional-packages" "openrc openssh-server"
    ^distrobox enter -nw --clean-path --name $container_name -- sudo rc-update add sshd default
}

export def dt-debian [container_name: string = "debian"]: nothing -> bool {
    if (dt-create-ilm $container_name quay.io/toolbx-images/debian-toolbox:latest "--init" "--additional-packages" "systemd libpam-systemd openssh-server") {
        ^distrobox enter -nw --clean-path --name $container_name -- sudo systemctl enable sshd
    }
}

export def dt-ubuntu [container_name: string = "ubuntu"]: nothing -> bool {
    if (dt-create-ilm $container_name quay.io/toolbx/ubuntu-toolbox:latest "--init" "--additional-packages" "systemd libpam-systemd openssh-server") {
        ^distrobox enter -nw --clean-path --name $container_name -- sudo systemctl enable sshd
    }
}

export def dt-arch [container_name: string = "arch"]: nothing -> bool {
    if (dt-create-ilm $container_name quay.io/toolbx/arch-toolbox:latest "--yes" "--init" "--additional-packages" "systemd openssh") {
        ^distrobox enter -nw --clean-path --name $container_name -- sudo systemctl enable sshd
    }
}

export def dt-tw [container_name: string = "tw"]: nothing -> bool {
    if (dt-create-ilm $container_name registry.opensuse.org/opensuse/tumbleweed:latest "--init" "--additional-packages" "systemd openssh-server") {
        ^distrobox enter -nw --clean-path --name $container_name -- sudo systemctl enable sshd
    }
}

export def dt-fedora [container_name: string = "fedora"]: nothing -> bool {
    if (dt-create-ilm $container_name quay.io/fedora/fedora-toolbox:43 "--init" "--additional-packages" "systemd openssh-server") {
        ^distrobox enter -nw --clean-path --name $container_name -- sudo systemctl enable sshd
    }
}

export def dt-centos [container_name: string = "centos"]: nothing -> bool {
    if (dt-create-ilm $container_name quay.io/centos/centos:stream10 "--init" "--additional-packages" "systemd openssh-server") {
        ^distrobox enter -nw --clean-path --name $container_name -- sudo systemctl enable sshd
    }
}

export def dt-nix [container_name: string = "deb-nix"]: nothing -> bool {
    if (dt-debian $container_name) {
        let setup_url = $env.ILM_SETUP_URL? | default "https://raw.githubusercontent.com/pervezfunctor/dotfiles/main/share/installers/setup"
        ^distrobox enter -nw --clean-path --name $container_name -- bash -c (curl -sSL $setup_url) -- nix
    }
}

export def dt-alpine-noinit [container_name: string = "alpine-noinit"]: nothing -> bool {
    let pkgs = "gcc libc-dev make gzip zsh git curl neovim tmux ripgrep luarocks fzf eza zoxide github-cli delta bat trash-cli"
    dt-create $container_name quay.io/toolbx-images/alpine-toolbox:latest "--additional-packages" $pkgs
}

export def dt-alpine-edge-noinit [
    container_name: string = "alpine-edge-noinit"
]: nothing -> bool {
    let pkgs = "gcc libc-dev make gzip zsh git curl neovim tmux ripgrep luarocks fzf eza zoxide github-cli delta bat trash-cli"
    dt-create $container_name quay.io/toolbx-images/alpine-toolbox:edge "--additional-packages" $pkgs
}

export def dt-dev-default []: nothing -> nothing {
    let setup_url = $env.ILM_SETUP_URL? | default "https://raw.githubusercontent.com/pervezfunctor/dotfiles/main/share/installers/setup"
    distrobox create --yes
    ^distrobox enter -nw --clean-path -- bash -c (curl -sSL $setup_url) -- dt-dev-atomic
    slog "Default distrobox created!"
}

export def dt-dev [os: string = "fedora", container_name: string = "dev"]: nothing -> bool {
    slog "Creating default distrobox"

    let valid_os = ["ubuntu" "debian" "arch" "tw" "fedora"]
    if not ($os in $valid_os) {
        fail $"Invalid OS type: ($os)"
        slog "Valid options are: ubuntu, debian, arch, tw, fedora"
        return false
    }

    match $os {
        "ubuntu" => { dt-ubuntu $container_name }
        "debian" => { dt-debian $container_name }
        "arch" => { dt-arch $container_name }
        "tw" => { dt-tw $container_name }
        "fedora" => { dt-fedora $container_name }
    }

    let setup_url = $env.ILM_SETUP_URL? | default "https://raw.githubusercontent.com/pervezfunctor/dotfiles/main/share/installers/setup"
    if (^distrobox enter -nw --clean-path --name $container_name -- bash -c (curl -sSL $setup_url) -- dt-dev-atomic) {
        slog $"Distrobox ($container_name) setup successfully"
        slog $"Use dte ($container_name) to enter"
        true
    } else {
        fail $"Failed to setup distrobox ($container_name)"
        false
    }
}

export def dt-main-install [
    distro: string
    mainstall: string
    container_name?: string
]: nothing -> nothing {
    let name = $container_name | default $"($distro)-($mainstall)"

    match $distro {
        "ubuntu" => { dt-ubuntu $name }
        "debian" => { dt-debian $name }
        "arch" => { dt-arch $name }
        "tw" => { dt-tw $name }
        "fedora" => { dt-fedora $name }
    }

    let setup_url = $env.ILM_SETUP_URL? | default "https://raw.githubusercontent.com/pervezfunctor/dotfiles/main/share/installers/setup"
    ^distrobox enter -nw --clean-path --name $name -- bash -c (curl -sSL $setup_url) -- $mainstall
}

export def dt-group-install [
    distro: string
    groupstall: string
    name?: string
]: nothing -> nothing {
    let container_name = $name | default $"($distro)-($groupstall)-test"

    match $distro {
        "ubuntu" => { dt-ubuntu $container_name }
        "debian" => { dt-debian $container_name }
        "arch" => { dt-arch $container_name }
        "tw" => { dt-tw $container_name }
        "fedora" => { dt-fedora $container_name }
    }

    let setup_url = $env.ILM_SETUP_URL? | default "https://raw.githubusercontent.com/pervezfunctor/dotfiles/main/share/installers/setup"
    ^distrobox enter -nw --clean-path --name $container_name -- bash -c (curl -sSL $setup_url)
    ^distrobox enter -nw --clean-path --name $container_name -- ilmg $"@($groupstall)"
}

export def dt-ublue-all []: nothing -> nothing {
    slog "Creating Bluefin, Wolfi and Ublue distroboxes"
    dt-bluefin
    dt-wolfi
    dt-docker
    dt-incus

    ^distrobox create --hostname ubuntu-ublue --yes --image ghcr.io/ublue-os/ubuntu-toolbox:latest --init --additional-packages "systemd libpam-systemd" --home ($env.BOXES_DIR | path join "ubuntu-ublue") --name ubuntu-ublue

    ^distrobox create --hostname fedora-ublue --yes --image ghcr.io/ublue-os/fedora-toolbox:latest --init --additional-packages "systemd" --home ($env.BOXES_DIR | path join "fedora-ublue") --name fedora-ublue

    ^distrobox create --hostname arch-ublue --yes --image ghcr.io/ublue-os/arch-distrobox:latest --init --additional-packages "systemd" --home ($env.BOXES_DIR | path join "arch-ublue") --name arch-ublue

    slog "Creating Bluefin, Wolfi and Ublue distroboxes done!"
}

export def dt-alpine-toolbox [container_name: string = "alpine-toolbox"]: nothing -> bool {
    dt-create $container_name quay.io/toolbx-images/alpine-toolbox:latest
}

export def dt-arch-toolbox [container_name: string = "arch-toolbox"]: nothing -> bool {
    dt-create $container_name quay.io/toolbx/arch-toolbox:latest "--init" "--additional-packages" "systemd"
}

export def dt-fedora-toolbox [container_name: string = "fedora-toolbox"]: nothing -> bool {
    dt-create $container_name quay.io/fedora/fedora-toolbox:43 "--init" "--additional-packages" "systemd"
}

export def dt-centos-toolbox [container_name: string = "centos-toolbox"]: nothing -> bool {
    dt-create $container_name quay.io/toolbx-images/centos-toolbox:latest "--init" "--additional-packages" "systemd"
}

export def dt-debian-toolbox [container_name: string = "debian-toolbox"]: nothing -> bool {
    dt-create $container_name quay.io/toolbx-images/debian-toolbox:latest "--init" "--additional-packages" "systemd"
}

export def dt-rockylinux-toolbox [
    container_name: string = "rockylinux-toolbox"
]: nothing -> bool {
    dt-create $container_name quay.io/toolbx-images/rockylinux-toolbox:latest "--init" "--additional-packages" "systemd"
}

export def dt-ubuntu-toolbox [container_name: string = "ubuntu-toolbox"]: nothing -> bool {
    dt-create $container_name quay.io/toolbx/ubuntu-toolbox:latest "--init" "--additional-packages" "systemd libpam-systemd"
}

export def dt-toolbox-all []: nothing -> nothing {
    dt-alpine-toolbox | ignore
    dt-arch-toolbox | ignore
    dt-fedora-toolbox | ignore
    dt-centos-toolbox | ignore
    dt-debian-toolbox | ignore
    dt-rockylinux-toolbox | ignore
    dt-ubuntu-toolbox | ignore
}

export def dt-nvidia-container-toolkit [container_name: string = "example-nvidia-toolkit"]: nothing -> nothing {
    if (has-cmd podman) {
        dt-create $container_name docker.io/nvidia/cuda "--additional-flags" "--gpus all"
    } else if (has-cmd docker) {
        dt-create $container_name docker.io/nvidia/cuda "--additional-flags" "--gpus all --device=nvidia.com/gpu=all"
    } else {
        warn "podman or docker not found"
    }
}

export def dt-to-image [image_name: string]: nothing -> nothing {
    if (has-cmd podman) {
        podman container commit -p dt-name $image_name
        podman save $"($image_name):latest" | bzip2 save $"($image_name).tar.bz"
    } else if (has-cmd docker) {
        docker container commit -p dt-name $image_name
        docker save $"($image_name):latest" | gzip save $"($image_name).tar.gz"
    }
}

export def dt-from-image [image: string]: nothing -> nothing {
    let container_name = $image
    slog $"Creating distrobox from image ($image)"

    if (^distrobox create --hostname $container_name --yes --image $"($image):latest" --name $container_name) {
        dt-enter $container_name
        slog $"Done creating distrobox from image ($image)"
    }
}

export def dt-containers []: nothing -> nothing {
    podman ps -a -s
}

export def dt-static-network-create [
    network: string = "default"
    subnet: string = "192.168.100.0/24"
]: nothing -> nothing {
    podman network create --subnet=$subnet $network
}

export def dt-static-network-remove [network: string = "default"]: nothing -> nothing {
    podman network rm $network
}

export def dt-static-ip [
    container_name: string = "static-box"
    ip_addr: string = "192.168.100.10"
]: nothing -> nothing {
    slog $"Creating distrobox ($container_name) with static IP ($ip_addr)"
    ^distrobox create --yes --image ubuntu:22.04 --name $container_name --unshare-netns --additional-flags $"--network default --ip ($ip_addr)"
}

# ============================================
# Root Container Management
# ============================================

export def dt-root-list []: nothing -> list<string> {
    distrobox list --root --no-color | tail -n +2 | awk '{print $3}' | lines
}

export def dt-root-exists [container_name: string]: nothing -> bool {
    distrobox list --root | grep -Fq -- $container_name
}

export def dt-root-ip [container_name: string]: nothing -> string {
    if ($container_name | is-empty) {
        print -e "Usage: dt-root-ip <container-name>"
        print -e "Shows the IP address of a distrobox container"
        return ""
    }

    if not (dt-root-exists $container_name) {
        print -e $"Error: Container '($container_name)' not found"
        return ""
    }

    let engine = if (has-cmd podman) and (sudo podman ps -a --format "{{.Names}}" | grep -Fqx -- $container_name) {
        "podman"
    } else if (has-cmd docker) and (docker ps -a --format "{{.Names}}" | grep -Fqx -- $container_name) {
        "docker"
    } else {
        print -e $"Error: Could not find container '($container_name)'"
        return ""
    }

    let ip = if $engine == "podman" {
        sudo podman inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $container_name
    } else {
        docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $container_name
    }

    if ($ip | is-empty) {
        print -e $"Error: Container '($container_name)' does not have an IP"
        return ""
    }

    $ip
}

export def dt-root-ssh [
    container_name: string
    user?: string
    port?: int
]: nothing -> nothing {
    let user_name = $user | default $env.USER
    let port_num = $port | default 22
    if ($container_name | is-empty) {
        print -e "Usage: dt-root-ssh <container-name> [user] [port]"
        return
    }

    let ip = (dt-root-ip $container_name)
    if ($ip | is-empty) {
        print -e $"Error: Could not determine IP for container '($container_name)'"
        return
    }

    print $"Connecting to ($container_name) at ($ip):($port_num) as ($user_name)..."
    ssh -p $port_num $"($user_name)@($ip)"
}

def check-whiptail []: nothing -> bool {
    if (has-cmd whiptail) {
        return true
    }

    print "Error: whiptail is not installed."
    print "On Ubuntu/Debian: sudo apt install whiptail"
    print "On Fedora: sudo dnf install newt"
    print "On Arch: sudo pacman -S newt"
    false
}

export def dt-root-ssh-tui [
    user?: string
    port?: int
]: nothing -> nothing {
    let user_name = $user | default $env.USER
    let port_num = $port | default 22

    if not (check-whiptail) {
        return
    }

    let containers = (dt-root-list)

    if ($containers | is-empty) {
        whiptail --title "Distrobox SSH" --msgbox "No distrobox containers found." 10 40
        return
    }

    let menu_items = ($containers | each {|container|
        let ip = try { dt-root-ip $container } catch { "IP not available" }
        [$container $ip]
    } | flatten)

    let selected = (whiptail --title "Distrobox SSH" --menu $"Select a container to SSH into (as ($user_name) on port ($port_num)):" 20 60 10 ...$menu_items 3>&1 1>&2 2>&3)

    if ($selected | is-empty) {
        print "Cancelled."
        return
    }

    let ip = (dt-root-ip $selected)
    if ($ip | is-empty) {
        whiptail --title "Error" --msgbox $"Could not determine IP for container '($selected)'" 10 40
        return
    }

    print $"Connecting to ($selected) at ($ip):($port_num) as ($user_name)..."
    ssh -p $port_num $"($user_name)@($ip)"
}

export def dt-root-list-ips []: nothing -> nothing {
    let containers = (dt-root-list)

    if ($containers | is-empty) {
        print "No distrobox containers found."
        return
    }

    print "Distrobox Containers and IP Addresses:"
    print "====================================="
    print "Container Name       IP Address"
    print "-------------------------------------"

    for container in $containers {
        let ip = try { dt-root-ip $container } catch { "N/A" }
        print $"($container | fill -a l -w 20) ($ip | fill -a l -w 15)"
    }
}

export def vscode-dt-root-ssh [
    container_name: string = "docker"
    user?: string
    port?: int
]: nothing -> nothing {
    let user_name = $user | default $env.USER
    let port_num = $port | default 22

    if ($container_name | is-empty) {
        print -e "Usage: vscode-dt-root-ssh <container-name> [user] [port]"
        return
    }

    let ip = (dt-root-ip $container_name)
    if ($ip | is-empty) {
        print -e $"Error: Could not determine IP for container '($container_name)'"
        return
    }

    if not (has-cmd code) {
        print "VS Code not found."
    }

    print $"Connecting to ($container_name) at ($ip):($port_num) as ($user_name)..."
    code --remote $"ssh-remote+($user_name)@($ip)"
}

export def show-completion-info [distro: string, dt_name: string]: nothing -> nothing {
    success "🎉 === Distrobox Creation Complete ==="
    print ""
    slog "📦 Container Details:"
    print $"  Name: ($dt_name)"
    print $"  Distribution: ($distro)"
    print $"  Home Directory: ($env.BOXES_DIR)/($dt_name)"
    print ""

    slog "🚀 Useful Commands:"
    print "  List containers:      dt list"
    print $"  Enter container:      dt enter ($dt_name)"
    print $"  Delete container:     dt delete ($dt_name)"
    print $"  Stop container:       dt stop ($dt_name)"
    print "If you need ssh access to the container, run inside container:"
    print "   dt-ssh-enable <port-no>"
    print "Afterwards you can ssh to the container from host using:"
    print $"   ssh -p <port-no> $env.USER@($dt_name)"
}
