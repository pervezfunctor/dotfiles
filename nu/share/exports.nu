#! /usr/bin/env nu

use utils.nu *

export-env {
    $env.LANG = ($env.LANG? | default "en_US.UTF-8")
    $env.HOMEBREW_NO_BOTTLE_SOURCE_FALLBACK = ($env.HOMEBREW_NO_BOTTLE_SOURCE_FALLBACK? | default 1)
    $env.ELECTRON_OZONE_PLATFORM_HINT = ($env.ELECTRON_OZONE_PLATFORM_HINT? | default "wayland")
    $env.LIBVIRT_DEFAULT_URI = ($env.LIBVIRT_DEFAULT_URI? | default "qemu:///system")
    $env.DOTNET_ROOT = ($env.DOTNET_ROOT? | default ($env.HOME | path join ".dotnet"))
    $env.GOPATH = ($env.GOPATH? | default ($env.HOME | path join "go"))
    $env.VOLTA_HOME = ($env.VOLTA_HOME? | default ($env.HOME | path join ".volta"))
    $env.XDG_DATA_HOME = ($env.XDG_DATA_HOME? | default ($env.HOME | path join ".local" "share"))
    $env.XDG_CACHE_HOME = ($env.XDG_CACHE_HOME? | default ($env.HOME | path join ".cache"))
}

export def --env init-exports [] {
    for p in [
        "/usr/bin"
        "/snap/bin"
        ($env.GOPATH | path join "bin")
        ($env.XDG_CONFIG_HOME | path join "emacs" "bin")
        ($env.HOME | path join ".local" "bin")
        ($env.HOME | path join "bin")
        ($env.HOME | path join ".bin")
        ($env.DOT_DIR | path join "bin")
        ($env.DOT_DIR | path join "bin" "vt")
        ($env.HOME | path join "Applications")
        ($env.HOME | path join "AppImages")
        ($env.HOME | path join ".local" "share" "pypoetry")
        ($env.XDG_CONFIG_HOME | path join "Code" "User" "globalStorage" "ms-vscode-remote.remote-containers" "cli-bin")
        ($env.HOME | path join ".console-ninja" ".bin")
        ($env.HOME | path join ".pixi" "bin")
        ($env.VOLTA_HOME | path join "bin")
        ($env.HOME | path join ".cargo" "bin")
    ] {
        spath-export $p
    }

    let user_docker = ($env.HOME | path join "bin" "docker")
    if ($user_docker | path exists) {
        let uid = ((do -i { ^id -u } | complete).stdout | str trim)
        if ($uid | is-not-empty) {
            $env.DOCKER_HOST = $"unix:///run/user/($uid)/docker.sock"
        }
    }
}

export def main [] {
    print "Use 'source-env exports.nu' for defaults or 'init-exports' to apply PATH additions."
}