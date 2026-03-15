#! /usr/bin/env nu

use utils.nu *

def toolbox-create [container_name: string, ...args: string] {
    if not (has-cmd toolbox) {
        warn "toolbox not installed"
        return false
    }

    slog $"Creating toolbox ($container_name)"
    let result = (do -i { ^toolbox create --assumeyes ...$args $container_name } | complete)
    if $result.exit_code == 0 {
        slog $"Done creating toolbox ($container_name)"
        true
    } else {
        false
    }
}

def toolbox-enter [container_name: string] {
    do -i { ^toolbox enter $container_name }
}

export def tbox-alpine [container_name: string = "alpine"] {
    if (toolbox-create $container_name "--image" "quay.io/toolbx-images/alpine-toolbox:latest") { toolbox-enter $container_name }
}

export def tbox-arch [container_name: string = "arch"] {
    if (toolbox-create $container_name "--distro" "arch") { toolbox-enter $container_name }
}

export def tbox-fedora [container_name: string = "fedora"] {
    if (toolbox-create $container_name "--distro" "fedora") { toolbox-enter $container_name }
}

export def tbox-ubuntu [container_name: string = "ubuntu"] {
    if (toolbox-create $container_name "--distro" "ubuntu" "--release" "24.10") { toolbox-enter $container_name }
}

export def tbox-tw [container_name: string = "tw"] {
    if (toolbox-create $container_name "--image" "quay.io/toolbx-images/opensuse-toolbox:tumbleweed") { toolbox-enter $container_name }
}

export def tbox-rocky [container_name: string = "rocky"] {
    if (toolbox-create $container_name "--image" "quay.io/rockylinux/rockylinux:9") { toolbox-enter $container_name }
}

export def tbox-centos [container_name: string = "centos"] {
    if (toolbox-create $container_name "--image" "quay.io/toolbx-images/centos-toolbox:latest") { toolbox-enter $container_name }
}

export def tbox-debian [container_name: string = "debian"] {
    if (toolbox-create $container_name "--image" "quay.io/toolbx-images/debian-toolbox:latest") { toolbox-enter $container_name }
}

export def tbox-rhel [container_name: string = "rhel"] {
    if (toolbox-create $container_name "--image" "registry.access.redhat.com/ubi9/ubi-toolbox:latest") { toolbox-enter $container_name }
}

export def tbox-create-all [] {
    for spec in [
        [arch "--distro" "arch"]
        [fedora "--distro" "fedora"]
        [ubuntu "--distro" "ubuntu" "--release" "24.10"]
        [tw "--image" "quay.io/toolbx-images/opensuse-toolbox:tumbleweed"]
        [rocky "--image" "quay.io/rockylinux/rockylinux:9"]
        [debian "--image" "quay.io/toolbx-images/debian-toolbox:latest"]
    ] {
        toolbox-create $spec.0 ...($spec | skip 1) | ignore
    }
}

export def tbox-group [group: string = "shell"] {
    if not (has-cmd toolbox) {
        warn "toolbox not installed"
        return
    }

    do -i { ^toolbox create --assumeyes } | ignore
    do -i { ^toolbox run bash -c (http get $env.ILM_SETUP_URL) -- $group }
}

export def tbox-dev [] {
    tbox-group "dt-dev-atomic"
}