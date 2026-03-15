#! /usr/bin/env nu

use utils.nu *
use fns.nu *

def boxes-root [] {
    $env.BOXES_DIR? | default ($env.HOME | path join ".local" "share" "distrobox")
}

export def sup [] {
    if (is-ubuntu) {
        sudo apt-get -qq update
        sudo apt-get -qq -y upgrade
    } else if (is-atomic) {
        sudo rpm-ostree upgrade
    } else if (is-rh) {
        sudo dnf update -q -y
        sudo dnf upgrade -q -y
    } else if (is-tw) {
        sudo zypper refresh
        sudo zypper --non-interactive --quiet dup
    } else if (is-mac) {
        brew update
        brew upgrade
    } else if (is-arch) {
        sudo pacman -Syu --noconfirm --quiet
    } else {
        warn "Unknown OS. Cannot upgrade."
    }
}

export def nix-update-wsl [profile: string = "wsl"] {
    let nix_config = ($env.HOME | path join "nix-config")
    let hm_config = ($env.DOT_DIR | path join "extras" "home-manager")

    if (dir-exists $nix_config) {
        nix flake update $nix_config
        sudo nixos-rebuild switch --flake $"($nix_config)#($profile)"
    } else if (dir-exists $hm_config) {
        nix flake update $hm_config
        sudo nixos-rebuild switch --flake $"($nix_config)#($profile)"
    } else {
        fail $"Cannot find config ($nix_config) or ($hm_config)"
    }
}

export def nix-update-mac [profile: string = "mac"] {
    let darwin_config = ($env.HOME | path join "darwin-config")
    let hm_config = ($env.DOT_DIR | path join "extras" "home-manager")

    if (dir-exists $darwin_config) {
        nix flake update $darwin_config
        sudo darwin-rebuild switch --flake $"($darwin_config)#($profile)"
    } else if (dir-exists $hm_config) {
        nix flake update $hm_config
        sudo darwin-rebuild switch --flake $"($darwin_config)#($profile)"
    } else {
        fail $"Cannot find config ($darwin_config) or ($hm_config)"
    }
}

export def gpp [...args: string] {
    safe-push ...$args | ignore
}

export def dtrc [container_name: string, ...args: string] {
    if ($args | is-empty) {
        fail "Usage: dtrc <container_name> <command>"
        return
    }
    distrobox run --name $container_name -- ...$args
}

export def dtsa [] {
    let result = (do -i { ^bash -lc "distrobox list --no-color | awk 'NR>1 && \$3 == \"Up\" {print \$2}'" } | complete)
    for container in ($result.stdout | lines | where { |line| $line | is-not-empty }) {
        print $"Stopping ($container)..."
        distrobox stop $container
    }
}

export def dtld [] {
    do -i { ^bash -lc "distrobox list --no-color | column -t -s '|'" }
}

export def dtexp [container_name: string, app_command: string] {
    distrobox export --name $container_name --app $app_command --export-path ($env.HOME | path join ".local" "bin")
}

export def dtimp [container_name: string, app_command: string] {
    distrobox enter --name $container_name -- distrobox-export --app $app_command --export-path ($env.HOME | path join ".local" "bin")
}

export def dtsh [container_name: string, shell: string = "bash"] {
    distrobox enter --name $container_name --additional-flags $"--shell ($shell)"
}

export def dtmount [container_name: string, host_path: string, container_path: string] {
    distrobox enter --name $container_name --additional-flags $"--volume ($host_path):($container_path)"
}

export def --env dtbackup [container_name: string] {
    let root = (boxes-root)
    let backup_dir = ($root | path join "backups")
    mkdir $backup_dir
    print $"Backing up ($container_name) to ($backup_dir | path join $'($container_name).tar.gz')"
    do -i { ^distrobox stop $container_name } | ignore
    let archive = ($backup_dir | path join $"($container_name).tar.gz")
    do -i { ^tar -czf $archive -C $root $container_name }
}

export def --env dtrestore [container_name: string] {
    let root = (boxes-root)
    let backup_dir = ($root | path join "backups")
    let archive = ($backup_dir | path join $"($container_name).tar.gz")

    if not ($archive | path exists) {
        fail $"Backup not found: ($archive)"
        return
    }

    do -i { ^tar -xzf $archive -C $root }
    print $"Restored ($container_name) from backup"
}

export def dtd [container_name: string, ...args: string] {
    distrobox rm $container_name ...$args
    srm ((boxes-root) | path join $container_name)
}

export def rdtd [container_name: string, ...args: string] {
    distrobox rm --root $container_name ...$args
    srm ((boxes-root) | path join $container_name)
}

export def quiet-echo [message: string, --quiet] {
    if not $quiet {
        print $message
    }
}

export def flatpak-aliases [] {
    [
        { cmd: "wezterm", flatpak_id: "org.wezfurlong.wezterm" }
        { cmd: "clion", flatpak_id: "com.jetbrains.CLion" }
        { cmd: "chrome", flatpak_id: "com.google.Chrome" }
        { cmd: "code", flatpak_id: "com.visualstudio.code" }
        { cmd: "nvim", flatpak_id: "io.neovim.nvim" }
        { cmd: "emacs", flatpak_id: "org.gnu.emacs" }
    ]
}

export def flatpak-alias [cmd: string, flatpak_id: string, --quiet] {
    if not (has-cmd flatpak) {
        if not $quiet { warn "flatpak command not found" }
        return { ok: false, code: 4, command: $cmd, flatpak_id: $flatpak_id, definition: null }
    }

    if (has-cmd $cmd) {
        if not $quiet { warn $"($cmd) already exists, skipping flatpak alias creation" }
        return { ok: false, code: 5, command: $cmd, flatpak_id: $flatpak_id, definition: null }
    }

    let installed = (try { flatpak list --columns=application | lines | any { |it| $it == $flatpak_id } } catch { false })
    if not $installed {
        if not $quiet { warn $"Flatpak app '($flatpak_id)' not installed" }
        return { ok: false, code: 8, command: $cmd, flatpak_id: $flatpak_id, definition: null }
    }

    let definition = $"flatpak run ($flatpak_id)"
    if not $quiet { print $"✨ Suggested Nushell wrapper: def ($cmd) [] { ($definition) }" }
    { ok: true, code: 0, command: $cmd, flatpak_id: $flatpak_id, definition: $definition }
}

export def flatpak-aliases-create [--quiet] {
    if ($env.CONTAINER_ID? | is-not-empty) {
        if not $quiet { print "📦 In a container environment, skipping flatpak alias creation" }
        return []
    }

    flatpak-aliases | each { |item| flatpak-alias $item.cmd $item.flatpak_id --quiet=$quiet }
}

export def --env fcd [] {
    if not (has-cmd fzf) {
        fail "fzf not installed"
        return
    }

    let result = (do -i { ^bash -lc "find . -type d -not -path '*/.*' | fzf" } | complete)
    let dir = ($result.stdout | str trim)
    if ($dir | is-not-empty) {
        cd $dir
        ls
    }
}

export def fvim [] {
    if not (has-cmd fzf) {
        fail "fzf not installed"
        return
    }

    let result = (do -i { ^bash -lc "find . -type f -not -path '*/.*' | fzf" } | complete)
    let file = ($result.stdout | str trim)
    if ($file | is-not-empty) {
        ^nvim $file
    }
}

export def uv-jupyter [] {
    let dir = ($env.HOME | path join "jupyter-standalone")
    let jupyter = ($dir | path join ".venv" "bin" "jupyter")

    if not (dir-exists $dir) {
        warn $"Directory ($dir) does not exist"
        return
    }

    ^$jupyter lab
}

export def uv-marimo [] {
    let dir = ($env.HOME | path join "marimo-standalone")
    if not (dir-exists $dir) {
        warn $"Directory ($dir) does not exist"
        return
    }

    do -i { ^bash -lc $"cd '($dir)' && uv run marimo edit" }
}