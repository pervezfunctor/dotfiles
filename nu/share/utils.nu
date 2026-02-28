#! /usr/bin/env nu

use std/log

export-env {
    $env.DOT_DIR = ($env.USE_DOT_DIR? | default $env.HOME | path join ".ilm")
    $env.XDG_CONFIG_HOME = ($env.XDG_CONFIG_HOME? | default ($env.HOME | path join ".config"))
    $env.ILM_BASE_URL = "https://raw.githubusercontent.com/pervezfunctor/dotfiles/main"
    $env.ILM_SETUP_URL = $"($env.ILM_BASE_URL)/share/installers/setup"
    $env.BOXES_DIR = ($env.USE_BOXES_DIR? | default ($env.HOME | path join ".boxes"))
    $env.ILM_LOG_DIR = ($env.XDG_STATE_HOME? | default ($env.HOME | path join ".local" "state")
        | path join "ilm" "logs")
}

export def reset-logs []: nothing -> nothing {
    slog "Removing old logs"
    rm -rf $env.ILM_LOG_DIR
}

export def init-logs []: nothing -> nothing {
    mkdir $env.ILM_LOG_DIR

    touch ($env.ILM_LOG_DIR | path join ".dotfiles-output.log")
    touch ($env.ILM_LOG_DIR | path join ".dotfiles-error.log")
    touch ($env.ILM_LOG_DIR | path join "slog.log")
    touch ($env.ILM_LOG_DIR | path join "fail.log")
    touch ($env.ILM_LOG_DIR | path join "warn.log")
    touch ($env.ILM_LOG_DIR | path join "info.log")
    touch ($env.ILM_LOG_DIR | path join "success.log")
}

export def slog [message: string]: nothing -> nothing {
    let log_line = $"INFO ($message)"
    $log_line | save --append ($env.ILM_LOG_DIR | path join "slog.log")
    log info $message
}

export def fail [message: string]: nothing -> nothing {
    let log_line = $"FAIL ($message)"
    $log_line | save --append ($env.ILM_LOG_DIR | path join "fail.log")
    log error $message
}

export def warn [message: string]: nothing -> nothing {
    let log_line = $"WARN ($message)"
    $log_line | save --append ($env.ILM_LOG_DIR | path join "warn.log")
    log warning $message
}

export def success [message: string]: nothing -> nothing {
    let log_line = $"OK ($message)"
    $log_line | save --append ($env.ILM_LOG_DIR | path join "success.log")
    log info $"[OK] ($message)"
}

export def info [message: string]: nothing -> nothing {
    let log_line = $"INFO ($message)"
    $log_line | save --append ($env.ILM_LOG_DIR | path join "info.log")
    log info $message
}

export def dir-exists [path: string]: nothing -> bool {
    ($path | path exists) and ($path | path type) == "dir"
}

export def file-exists [path: string]: nothing -> bool {
    ($path | path exists) and ($path | path type) == "file"
}

export def exists [path: string]: nothing -> bool {
    $path | path exists
}

export def smd [path: string]: nothing -> bool {
    if (dir-exists $path) {
        return false
    }
    slog $"Creating directory ($path)"
    mkdir $path
    true
}

export def srm [...paths: string]: nothing -> nothing {
    for path in $paths {
        if not (exists $path) {
            continue
        }

        if ($path | path type) == "symlink" {
            rm $path
            slog $"Removing link ($path)"
        } else if (has-cmd trash-put) {
            ^trash-put $path
            slog $"Trashed ($path)"
        } else if (has-cmd trash) {
            ^trash $path
            slog $"Trashed ($path)"
        } else {
            backup-file $path
            rm $path
        }
    }
}

export def frm [...paths: string]: nothing -> nothing {
    for path in $paths {
        if not (exists $path) {
            continue
        }

        if ($path | path type) == "symlink" {
            rm $path
            slog $"Removing link ($path)"
        } else if (has-cmd trash-put) {
            ^trash-put $path
            slog $"Trashed ($path)"
        } else if (has-cmd trash) {
            ^trash $path
            slog $"Trashed ($path)"
        } else {
            warn $"removing file ($path)"
            rm $path
        }
    }
}

export def backup-file [path: string]: nothing -> bool {
    if not (file-exists $path) {
        warn $"File ($path) does not exist, no backup created"
        return false
    }

    let timestamp = (date now | format date "%Y%m%d-%H%M%S")
    let backup_path = $"($path).backup-($timestamp)"

    try {
        cp $path $backup_path
        slog $"Created backup of ($path | path basename) at ($backup_path)"
        true
    } catch {
        warn $"Failed to create backup of ($path)"
        false
    }
}

export def smv [source: string, dest: string]: nothing -> bool {
    if not (exists $source) {
        fail $"($source) does not exist, cannot move to ($dest)"
        return false
    }

    try {
        mv $source $dest
        slog $"Moved ($source) to ($dest)"
        true
    } catch {
        fail $"Failed to move ($source) to ($dest)"
        false
    }
}

export def fmv [source: string, dest: string]: nothing -> bool {
    if not (exists $source) {
        warn $"($source) does not exist, cannot move to ($dest)"
        return false
    }

    srm $dest
    slog $"Moving ($source) to ($dest)"

    try {
        mv $source $dest
        true
    } catch {
        fail $"Failed to move ($source) to ($dest)"
        false
    }
}

export def omv [source: string, dest: string]: nothing -> bool {
    if (exists $source) {
        srm $dest
    } else {
        return false
    }

    slog $"Moving ($source) to ($dest)"
    try {
        mv $source $dest
        true
    } catch {
        warn $"Failed to move ($source) to ($dest)"
        false
    }
}

export def safe-cp [source: string, dest: string]: nothing -> bool {
    if not (exists $source) {
        fail $"($source) does not exist, cannot copy to ($dest)"
        return false
    }

    if (exists $dest) {
        warn $"($dest) already exists, cannot copy ($source)"
        return false
    }

    slog $"Copying ($source) to ($dest)"
    try {
        cp -r $source $dest
        true
    } catch {
        false
    }
}

export def fcp [source: string, dest: string]: nothing -> bool {
    if not (exists $source) {
        fail $"($source) does not exist, cannot copy to ($dest)"
        return false
    }

    srm $dest
    slog $"Copying ($source) to ($dest)"

    try {
        cp -r $source $dest
        true
    } catch {
        fail $"Failed to copy ($source) to ($dest)"
        false
    }
}

export def sln [source: string, dest: string]: nothing -> bool {
    if not (exists $source) {
        fail $"($source) does not exist, link to ($dest) not created"
        return false
    }

    let dest_type = ($dest | path type)
    if $dest_type == "symlink" {
        srm $dest
    } else if $dest_type != null {
        warn $"($dest) exists and is not a symbolic link! Not creating link"
        return false
    }

    slog $"Creating link ($dest) to ($source)"
    try {
        ln -s $source $dest
        true
    } catch {
        fail $"Failed to create symbolic link from ($dest) to ($source)"
        false
    }
}

export def fln [source: string, dest: string]: nothing -> bool {
    if not (exists $source) {
        fail $"($source) does not exist, link to ($dest) not created"
        return false
    }

    frm $dest
    slog $"Creating link ($dest) to ($source)"
    ln -s $source $dest
}

export def ln-to-exists [target: string, link: string]: nothing -> bool {
    let readlink_cmd = if (is-mac) {
        if (has-cmd greadlink) {
            "greadlink"
        } else {
            fail "greadlink not found, cannot check if ($link) is a link"
            return false
            return false
        }
    } else {
        "readlink"
    }

    try {
        let resolved = (do { ^$readlink_cmd -f $link } | complete | get stdout | str trim)
        $target == $resolved
    } catch {
        false
    }
}

export def has-cmd [cmd: string]: nothing -> bool {
    which $cmd | is-not-empty
}

export def check-cmd [cmd: string]: nothing -> nothing {
    if not (has-cmd $cmd) {
        die $"Missing dependency: ($cmd)"
    }
}

export def check-cmds [...cmds: string]: nothing -> nothing {
    let missing = ($cmds | where { |cmd| not (has-cmd $cmd) })

    if ($missing | length) > 0 {
        echo "\n\e[1;31m❌ Missing required commands\e[0m\n"
        echo $"\e[1;34m📦 Missing:\e[0m ($missing | str join ' ')"
        echo "\e[1;34m💡 Install them before running this script.\e[0m\n"
        exit 1
    }
}

export def spath-export [path: string]: nothing -> nothing {
    if (dir-exists $path) {
        $env.PATH = $"($path):($env.PATH)"
    }
}

export def spath-export-unsafe [path: string]: nothing -> nothing {
    $env.PATH = $"($path):($env.PATH)"
}

export def is-mac []: nothing -> bool {
    ((sys host | get name) | str contains "darwin")
        or ((sys host | get name) | str contains "Darwin")
}

export def is-linux []: nothing -> bool {
    (sys host | get name) | str contains "Linux"
}

export def get-os []: nothing -> string {
    if ("/etc/os-release" | path exists) {
        open /etc/os-release
        | lines
        | parse "{key}={value}"
        | where key == "ID"
        | get 0?.value?
        | default (sys host | get name)
        | str downcase
    } else if ("/etc/lsb-release" | path exists) {
        open /etc/lsb-release
        | lines
        | parse "{key}={value}"
        | where key == "DISTRIB_ID"
        | get 0?.value?
        | default (sys host | get name)
        | str downcase
    } else if ("/etc/redhat-release" | path exists) {
        open /etc/redhat-release | lines | first 1 | split words | first 1 | str downcase
    } else {
        (sys host | get name) | str downcase
    }
}

export def is-debian []: nothing -> bool {
    (get-os) | str contains "debian"
}

export def is-ubuntu []: nothing -> bool {
    let os = (get-os)
    (($os | str contains "ubuntu") or ($os | str contains "neon")
        or ($os | str contains "elementary") or ($os | str contains "linuxmint")
        or ($os | str contains "pop") or ($os | str contains "zorin"))
}

export def is-tw []: nothing -> bool {
    (get-os) | str contains "tumbleweed"
}

export def is-arch []: nothing -> bool {
    let os = (get-os)
    (($os | str contains "arch") or ($os | str contains "cachyos")
        or ($os | str contains "endeavouros") or ($os | str contains "manjaro")
        or ($os | str contains "garuda"))
}

export def is-fedora []: nothing -> bool {
    let os = (get-os)
    ($os | str contains "fedora") or ($os | str contains "nobara")
}

export def is-rh []: nothing -> bool {
    (is-fedora) or (is-rocky) or (is-centos)
}

export def is-rocky []: nothing -> bool {
    ("/etc/redhat-release" | path exists) and ((open /etc/redhat-release) | str contains -i "rocky")
}

export def is-centos []: nothing -> bool {
    ("/etc/redhat-release" | path exists) and ((open /etc/redhat-release) | str contains -i "centos")
}

export def is-alpine []: nothing -> bool {
    ("/etc/alpine-release" | path exists) and (has-cmd apk)
}

export def is-wsl []: nothing -> bool {
    ("/proc/version" | path exists) and ((open /proc/version) | str contains -i "microsoft")
}

export def is-multipass []: nothing -> bool {
    let containerenv = "/run/cloud-init/instance-data.json"
    ($containerenv | path exists) and ((open $containerenv) | str contains "multipass")
}

export def is-toolbox []: nothing -> bool {
    if not (("/run/.containerenv" | path exists) or ("/.dockerenv" | path exists)) {
        return false
    }
    if ("/run/.toolboxenv" | path exists) {
        return true
    }
    if ("/run/.containerenv" | path exists) {
        return (open /run/.containerenv | str contains "toolbox")
    }
    false
}

export def is-distrobox []: nothing -> bool {
    $env.CONTAINER_ID? | is-not-empty
}

export def is-box []: nothing -> bool {
    (is-distrobox) or (is-toolbox) or (is-wsl)
}

export def is-nixos []: nothing -> bool {
    if ("/etc/os-release" | path exists) {
        if (open /etc/os-release | str contains "ID=nixos") {
            return true
        }
    }
    if (has-cmd nixos-version) {
        return true
    }
    if ("/etc/NIXOS" | path exists) {
        return true
    }
    false
}

export def is-proxmox []: nothing -> bool {
    (("/etc/pve/.version" | path exists)
        or ((has-cmd pveversion) and (do { ^pveversion } | complete | get stdout | str contains "pve"))
        or ((open /etc/os-release) | str contains -i "proxmox"))
}

export def is-apt []: nothing -> bool {
    (is-ubuntu) or (is-debian)
}

export def is-gnome []: nothing -> bool {
    let desktop = ($env.XDG_CURRENT_DESKTOP? | default "")
    (($desktop == "GNOME") or ($desktop == "ubuntu:GNOME")
        or ($desktop == "GNOME-Shell")
        or (($desktop | str contains "GNOME")
            and ($env.DESKTOP_SESSION? | default "" | str contains "ubuntu")))
}

export def is-kde []: nothing -> bool {
    let desktop = ($env.XDG_CURRENT_DESKTOP? | default "")
    let session = ($env.DESKTOP_SESSION? | default "")
    ($desktop == "KDE") or ($session == "plasma")
}

export def is-sway []: nothing -> bool {
    let desktop = ($env.XDG_CURRENT_DESKTOP? | default "")
    let session = ($env.DESKTOP_SESSION? | default "")
    ($desktop == "Sway") or ($session == "sway")
}

export def is-hyprland []: nothing -> bool {
    let desktop = ($env.XDG_CURRENT_DESKTOP? | default "")
    let session = ($env.DESKTOP_SESSION? | default "")
    ($desktop == "Hyprland") or ($session == "hyprland")
}

export def is-wayland []: nothing -> bool {
    $env.WAYLAND_DISPLAY? | is-not-empty
}

export def is-desktop []: nothing -> bool {
    let de_commands = [gnome-shell plasma-desktop startplasma-wayland niri hyprland sway mango]
    for cmd in $de_commands {
        if (has-cmd $cmd) {
            return true
        }
    }
    (($env.XDG_CURRENT_DESKTOP? | is-not-empty)
        or ($env.DESKTOP_SESSION? | is-not-empty)
        or ($env.XDG_SESSION_TYPE? == "wayland"))
}

export def is-kinoite []: nothing -> bool {
    let os = (open /etc/os-release)
    (($os.ID? | default "" | str contains -i "kinoite")
        or ($os.PRETTY_NAME? | default "" | str contains -i "kinoite"))
}

export def is-silverblue []: nothing -> bool {
    let os = (open /etc/os-release)
    (($os.ID? | default "" | str contains -i "silverblue")
        or ($os.PRETTY_NAME? | default "" | str contains -i "silverblue"))
}

export def is-sway-atomic []: nothing -> bool {
    let os = (open /etc/os-release)
    (($os.ID? | default "" | str contains -i "sway atomic")
        or ($os.PRETTY_NAME? | default "" | str contains -i "sway atomic")
        or ($os.VARIANT? == "Sway Atomic"))
}

export def is-cosmic-atomic []: nothing -> bool {
    let os = (open /etc/os-release)
    (($os.ID? | default "" | str contains "COSMIC")
        or ($os.PRETTY_NAME? | default "" | str contains "COSMIC"))
}

export def is-ublue []: nothing -> bool {
    (is-aurora) or (is-bluefin) or (is-bazzite)
}

export def is-aurora []: nothing -> bool {
    let os = (open /etc/os-release | str downcase)
    ($os | str contains "aurora")
}

export def is-bluefin []: nothing -> bool {
    let os = (open /etc/os-release | str downcase)
    ($os | str contains "bluefin")
}

export def is-bazzite []: nothing -> bool {
    let os = (open /etc/os-release | str downcase)
    ($os | str contains "bazzite")
}

export def is-std-atomic []: nothing -> bool {
    (is-kinoite) or (is-silverblue) or (is-sway-atomic) or (is-cosmic-atomic)
}

export def is-atomic []: nothing -> bool {
    (is-std-atomic) or (is-ublue)
}

export def ubuntu-version []: nothing -> string {
    if not (is-ubuntu) {
        return ""
    }
    open /etc/os-release | get VERSION_ID? | default ""
}

export def ubuntu-major-version []: nothing -> int {
    let version = (ubuntu-version)
    if ($version | is-empty) {
        return 0
    }
    $version | split row "." | first | into int
}

export def debian-version []: nothing -> string {
    if not (is-debian) {
        return ""
    }
    open /etc/os-release | get VERSION_ID? | default "" | split row "." | first
}

export def fedora-version []: nothing -> string {
    if not (is-fedora) {
        return ""
    }
    open /etc/os-release | get VERSION_ID? | default "" | split row "." | first
}

export def plasma-major-version []: nothing -> int {
    if not (has-cmd plasmashell) {
        return 0
    }
    (^plasmashell --version | split words | get 1 | split row "." | first | into int)
}

export def gnome-major-version []: nothing -> int {
    if not (has-cmd gnome-shell) {
        return 0
    }
    (^gnome-shell --version | split words | get 2 | split row "." | first | into int)
}

export def group-exists [group: string]: nothing -> bool {
    try {
        ^getent group $group | complete | get exit_code | $in == 0
    } catch {
        false
    }
}

export def user-in-group [user: string, group: string]: nothing -> bool {
    try {
        let groups = (^id -nG $user | str trim | split row " ")
        $group in $groups
    } catch {
        false
    }
}

export def current-user-in-group [group: string]: nothing -> bool {
    user-in-group $env.USER $group
}

export def group-create [group: string]: nothing -> bool {
    if (group-exists $group) {
        slog $"Group ($group) already exists"
        return true
    }

    try {
        sudo groupadd -r $group
        true
    } catch {
        slog $"Adding group ($group) failed"
        false
    }
}

export def add-user-to-group [user: string, group: string]: nothing -> bool {
    if not (group-exists $group) {
        warn $"Group ($group) does not exist, skipping"
        return false
    }

    if (user-in-group $user $group) {
        slog $"User ($user) already in group ($group)"
        return true
    }

    try {
        sudo usermod -aG $group $user
        slog $"Adding user ($user) to group ($group) done!"
        true
    } catch {
        warn $"Adding user ($user) to group ($group) failed"
        false
    }
}

export def add-user-to-groups [user: string, ...groups: string]: nothing -> nothing {
    for group in $groups {
        add-user-to-group $user $group
    }
}

export def ssh-key-exists []: nothing -> bool {
    ("~/.ssh/id_ed25519.pub" | path exists) or ("~/.ssh/id_rsa.pub" | path exists)
}

export def ssh-key-generate []: nothing -> nothing {
    smd ~/.ssh
    ^ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N "" -q
}

export def ssh-key-path []: nothing -> string {
    if ("~/.ssh/id_ed25519.pub" | path exists) {
        ~/.ssh/id_ed25519.pub | path expand
    } else if ("~/.ssh/id_rsa.pub" | path exists) {
        ~/.ssh/id_rsa.pub | path expand
    } else {
        ssh-key-generate
        ~/.ssh/id_ed25519.pub | path expand
    }
}

export def ssh-enable [port?: int]: nothing -> nothing {
    let sshd_config = "/etc/ssh/sshd_config"

    # Enable password authentication
    try {
        sudo sed -i -E 's/^#?PasswordAuthentication[[:space:]]+(no|yes)/PasswordAuthentication yes/' $sshd_config
    } catch {
        echo "PasswordAuthentication yes" | sudo tee -a $sshd_config | ignore
    }

    # Set port if provided
    if $port != null {
        try {
            sudo sed -i -E $"s/^#?Port[[:space:]]+[0-9]+/Port ($port)/" $sshd_config
        } catch {
            echo $"Port ($port)" | sudo tee -a $sshd_config | ignore
        }
    }

    # Restart SSH service
    try {
        sudo systemctl restart ssh
    } catch {
        sudo systemctl restart sshd
    }
}

export def sclone [source: string, dest: string, ...args: string]: nothing -> bool {
    frm $dest

    if (dir-exists $dest) {
        fail $"Destination directory ($dest) already exists. Cannot clone."
        return false
    }

    slog $"Cloning ($source) to ($dest)"
    try {
        git clone ...$args $source $dest
        true
    } catch {
        fail $"Failed to clone ($source) to ($dest)"
        false
    }
}

export def fclone [source: string, dest: string, ...args: string]: nothing -> bool {
    srm $dest

    if (dir-exists $dest) {
        fail $"Destination directory ($dest) already exists. Cannot clone."
        return false
    }

    slog $"Cloning ($source) to ($dest)"
    try {
        git clone ...$args $source $dest
        true
    } catch {
        fail $"Failed to clone ($source) to ($dest)"
        false
    }
}

export def clone-update [source: string, dest: string, ...args: string]: nothing -> bool {
    if not (dir-exists $dest) {
        slog $"Cloning ($source) to ($dest)"
        try {
            git clone ...$args $source $dest
            return true
        } catch {
            return false
        }
    }

    # Check if it's a git repo
    let is_git = try {
        cd $dest
        git rev-parse --is-inside-work-tree | complete | get exit_code | $in == 0
    } catch {
        false
    }

    if not $is_git {
        fail $"($dest) exists but is not a git repository"
        return false
    }

    slog $"Updating existing repository in ($dest)"

    cd $dest

    # Check remote matches
    let current_remote = try {
        git remote get-url origin | str trim
    } catch {
        ""
    }

    if $current_remote != $source {
        fail $"Remote repository in ($dest) does not match the provided source, skipping update"
        return false
    }

    # Get current and default branch
    let original_branch = try {
        git symbolic-ref --short HEAD | str trim
    } catch {
        ""
    }

    if ($original_branch | is-empty) {
        fail $"Cannot determine current branch in ($dest), skipping update"
        return false
    }

    let default_branch = try {
        git symbolic-ref refs/remotes/origin/HEAD | str replace "refs/remotes/origin/" ""
    } catch {
        ""
    }

    if ($default_branch | is-empty) {
        fail $"Cannot determine default branch in ($dest), skipping update"
        return false
    }

    # Check if dirty
    let is_dirty = try {
        (git status --porcelain | str trim | str length) > 0
    } catch {
        false
    }

    if ($original_branch != $default_branch) and $is_dirty {
        fail "Repository is dirty AND not on the default branch, skipping update"
        return false
    }

    # Stash if dirty and perform update
    let stashed = if $is_dirty {
        slog "Repository not clean, stashing changes"
        try {
            git stash --include-untracked
            true
        } catch {
            fail "Failed to stash changes"
            return false
        }
    } else {
        false
    }

    # Switch to default branch if needed
    if $original_branch != $default_branch {
        slog $"Switching to ($default_branch) branch for update"
        try {
            git checkout $default_branch
        } catch {
            fail $"Failed to switch to ($default_branch) branch"
            return false
        }
    }

    # Pull with rebase
    let pull_result = try {
        git pull --rebase
        true
    } catch {
        warn "Update failed, aborting rebase"
        git rebase --abort
        false
    }

    # Restore branch if needed
    if $original_branch != $default_branch {
        if $pull_result {
            git checkout $original_branch
        } else {
            slog $"Attempting to switch back to ($original_branch) branch..."
            try {
                git checkout $original_branch
            } catch {
                fail $"CRITICAL: Failed to switch back to ($original_branch) after failed update!"
            }
        }
    }

    # Unstash if we stashed
    if $stashed {
        unstash
    }

    $pull_result
}

export def unstash []: nothing -> nothing {
    slog "Attempting to apply stashed changes after failed update..."
    try {
        git stash show -p | git apply --check
        git stash apply
        git stash drop
    } catch {
        fail "Detected potential conflicts with stashed changes"
        fail "Your changes are preserved in the stash. Use 'git stash apply' manually."
    }
}

export def bi [...packages: string]: nothing -> nothing {
    if not (has-cmd brew) {
        warn "brew not installed, skipping brew packages"
        return
    }
    brew install -q ...$packages
}

export def bic [...packages: string]: nothing -> nothing {
    if not (has-cmd brew) {
        warn "brew not installed, skipping brew casks"
        return
    }
    brew install -q --cask ...$packages
}

export def bis [...packages: string]: nothing -> nothing {
    if not (has-cmd brew) {
        warn "brew not installed, skipping brew packages"
        return
    }

    let to_install = ($packages | where { |pkg| not (has-cmd $pkg) })
    if ($to_install | length) > 0 {
        for pkg in $to_install {
            slog $"brew package ($pkg) will be installed"
        }
        brew install -q ...$to_install
    }
}

export def mi [...packages: string]: nothing -> nothing {
    let mise_path = ~/.local/bin/mise
    if not ($mise_path | path exists) {
        warn "mise not installed, skipping mise packages"
        return
    }

    for pkg in $packages {
        slog $"Installing mise package ($pkg)"
        ^$mise_path use -g $pkg
    }
}

export def mis [...packages: string]: nothing -> nothing {
    let mise_path = ~/.local/bin/mise
    if not ($mise_path | path exists) {
        warn "mise not installed, skipping mise packages"
        return
    }

    for pkg in $packages {
        if not (has-cmd $pkg) {
            slog $"Installing mise package ($pkg)"
            ^$mise_path use -g $pkg
        }
    }
}

export def cargoi [...packages: string]: nothing -> nothing {
    if not (has-cmd cargo) {
        warn "cargo not installed, skipping cargo packages"
        return
    }

    for pkg in $packages {
        slog $"Installing cargo package ($pkg)"
        cargo +stable install --locked $pkg
    }
}

export def pyi [...packages: string]: nothing -> nothing {
    if not ((has-cmd pipx) or (has-cmd uv)) {
        warn "neither pipx nor uv installed, skipping packages"
        return
    }

    let installer = if (has-cmd uv) { "uv tool" } else { "pipx" }

    for pkg in $packages {
        slog $"Installing ($installer) package ($pkg)"
        if $installer == "uv tool" {
            uv tool install $pkg
        } else {
            pipx install $pkg
        }
    }
}

export def wis [...packages: string]: nothing -> nothing {
    if not (has-cmd webi) {
        warn "webi not installed, skipping webi packages"
        return
    }

    for pkg in $packages {
        slog $"Installing webi package ($pkg)"
        if not (has-cmd $pkg) {
            webi $pkg
        }
    }
}

export def fpi [...packages: string]: nothing -> nothing {
    if not (has-cmd flatpak) {
        warn "flatpak not installed, skipping flatpak packages"
        return
    }

    for pkg in $packages {
        slog $"Installing flatpak package ($pkg)"
        flatpak install -y --user flathub $pkg
    }
}

export def pi [...packages: string]: nothing -> nothing {
    if not (has-cmd pixi) {
        warn "pixi not installed, skipping pixi packages"
        return
    }

    for pkg in $packages {
        pixi global install $pkg
    }
}

export def pis [...packages: string]: nothing -> nothing {
    if not (has-cmd pixi) {
        warn "pixi not installed, skipping pixi packages"
        return
    }

    for pkg in $packages {
        if not (has-cmd $pkg) {
            pixi global install $pkg
        }
    }
}

export def flatpak-app-installed [app: string]: nothing -> bool {
    if not (has-cmd flatpak) {
        return false
    }
    try {
        (flatpak list | str contains $app)
    } catch {
        false
    }
}

export def check-flatpak-app-installed [app: string]: nothing -> nothing {
    if not (flatpak-app-installed $app) {
        warn $"($app) flatpak app not installed"
    }
}

export def ensure-stow []: nothing -> bool {
    (has-cmd stow) or (has-cmd nix)
}

export def stow-core [args: list]: nothing -> nothing {
    if (has-cmd stow) {
        stow ...$args
    } else if (has-cmd nix) {
        nix run --experimental-features 'nix-command flakes'
            nixpkgs#stow ...$args
    } else {
        warn "stow or nix must be installed"
    }
}

export def stowgf [...packages: string]: nothing -> nothing {
    if not (dir-exists $env.DOT_DIR) {
        warn $"stowgf: ($env.DOT_DIR) does not exist"
        return
    }

    for pkg in $packages {
        slog $"stow ($pkg)"
        srm ($env.XDG_CONFIG_HOME | path join $pkg)
        smd ($env.XDG_CONFIG_HOME | path join $pkg)
        stow-core [-d $env.DOT_DIR -t $env.HOME --dotfiles -R $pkg]
    }
}

export def stowdf [...packages: string]: nothing -> nothing {
    if not (dir-exists $env.DOT_DIR) {
        warn $"stowdf: ($env.DOT_DIR) does not exist"
        return
    }

    for pkg in $packages {
        slog $"stow ($pkg)"
        stow-core [-d $env.DOT_DIR -t $env.HOME --dotfiles $pkg]
    }
}

export def stownf [...packages: string]: nothing -> nothing {
    if not (dir-exists $env.DOT_DIR) {
        warn $"stownf: ($env.DOT_DIR) does not exist"
        return
    }

    for pkg in $packages {
        slog $"stow ($pkg)"
        stow-core [--no-folding -d $env.DOT_DIR -t $env.HOME --dotfiles -R $pkg]
    }
}

export def hms [profile?: string]: nothing -> bool {
    if not (has-cmd nix) {
        fail "nix not installed, cannot run hms"
        return false
    }

    let profile_name = $profile | default $env.USER
    let hms_dir = if (dir-exists ~/nix-config) {
        ~/nix-config | path expand
    } else if (dir-exists ($env.DOT_DIR | path join "extras" "home-manager")) {
        $env.DOT_DIR | path join "extras" "home-manager"
    } else {
        fail "nix-config not found, cannot run hms"
        return false
    }

    let flake_str = $"($hms_dir)#($profile_name)"
    try {
        nix run home-manager -- switch --flake $flake_str --impure -b bak
        true
    } catch {
        false
    }
}

export def is-ip [input: string]: nothing -> bool {
    $input | find -r '^((25[0-5]|2[0-4][0-9]|1?[0-9]{1,2})\.){3}(25[0-5]|2[0-4][0-9]|1?[0-9]{1,2})$'
        | is-not-empty
}

export def print-heading [title: string]: nothing -> nothing {
    let title_len = ($title | str length)
    let width = $title_len + 10
    let border = (seq 1 $width | each { "─" } | str join)

    echo $"\e[1;32m╭($border)╮\e[0m"
    echo $"\e[1;32m│\e[1;37m(5 | fill -w 5)(" ")($title)(5 | fill -w 5)\e[1;32m│\e[0m"
    echo $"\e[1;32m╰($border)╯\e[0m"
    echo ""
}

export def print-subheading [title: string]: nothing -> nothing {
    let border = (seq 1 ($title | str length) | each { "─" } | str join)
    echo $"\e[1;36m($title)\e[0m"
    echo $"\e[0;36m($border)\e[0m"
}

export def print-info-pair [key: string, value: string, key_width?: int]: nothing -> nothing {
    let width = $key_width | default 12
    let padding = $width - ($key | str length)
    echo $"\e[1m($key):\e[0m($padding | fill -w $padding)\e[0;33m($value)\e[0m"
}

export def print-info-pairs [key_width?: int, ...pairs: string]: nothing -> nothing {
    let width = $key_width | default 12
    for i in (seq 0 2 (($pairs | length) - 1)) {
        let key = $pairs | get $i
        let value = $pairs | get ($i + 1)
        print-info-pair $key $value $width
    }
}

export def print-command-info [description: string, command: string]: nothing -> nothing {
    info $description
    info $"  ($command)"
}

export def print-note [note: string]: nothing -> nothing {
    echo $"  \e[0;90m($note)\e[0m"
}

export def yes-or-no [prompt: string, --default(-d): string = "n"] {
    let valid_yes = ["y" "yes" "Y" "YES"]
    let valid_no = ["n" "no" "N" "NO"]

    mut result = ($default == "y")
    loop {
        let answer = (input $"($prompt) (y/n) [($default)]: ") | str trim
        let answer = if ($answer | is-empty) { $default } else { $answer }

        if $answer in $valid_yes {
            $result = true
            break
        } else if $answer in $valid_no {
            $result = false
            break
        } else {
            echo "Please answer yes or no."
        }
    }
    $result
}

export def select-one [prompt: string, ...items: string]: nothing -> string {
    if (has-cmd fzf) {
        $items | str join "\n" | fzf --prompt=$prompt --height=10 --layout=reverse
    } else if (has-cmd gum) {
        $items | str join "\n" | gum choose --header=$prompt
    } else {
        echo $prompt
        let selection = (input "Enter selection: ")
        $selection
    }
}

export def select-multi [prompt: string, ...items: string]: nothing -> list {
    if (has-cmd fzf) {
        $items | str join "\n" | fzf --prompt=$prompt --height=10 --layout=reverse --multi | lines
    } else if (has-cmd gum) {
        gum choose --no-limit --header=$prompt ...$items | lines
    } else {
        echo $"($prompt) (comma-separated)"
        let selection = (input "Enter selections: ")
        $selection | split row "," | each { str trim }
    }
}

export def source-if-exists [path: string]: nothing -> nothing {
    if ($path | path exists) {
        nu $path
    }
}

export def safe-append [line: string, file: string]: nothing -> bool {
    try {
        let content = (open $file | lines)
        if $line in $content {
            return true
        }
    } catch {
        # File doesn't exist, will create
    }

    slog $"Adding ($line) to ($file)"

    if not ($file | path exists) {
        try {
            touch $file
        } catch {
            fail $"Cannot create or access ($file) for appending"
            return false
        }
    }

    try {
        echo $line >> $file
        true
    } catch {
        fail $"Failed to append content to ($file)"
        false
    }
}

export def safe-prepend [line: string, file: string]: nothing -> bool {
    try {
        let content = (open $file | lines)
        if $line in $content {
            return true
        }
    } catch {
        # File doesn't exist
    }

    slog $"Prepending ($line) to ($file)"

    let tmpfile = (mktemp)
    try {
        echo $line | cat - $file | save -f $tmpfile
        mv $tmpfile $file
        true
    } catch {
        fail $"Failed to update ($file) with prepended content"
        rm -f $tmpfile
        false
    }
}

export def download-to [url: string, dest: string]: nothing -> bool {
    if (has-cmd curl) {
        try {
            curl -sSL $url -o $dest
            true
        } catch {
            false
        }
    } else if (has-cmd wget) {
        try {
            wget -nv $url -O $dest
            true
        } catch {
            false
        }
    } else {
        fail "curl or wget must be installed"
        false
    }
}

export def source-curl [url: string]: nothing -> bool {
    slog $"Sourcing: ($url)"
    let temp_file = (mktemp)

    if not (download-to $url $temp_file) {
        warn $"Failed to download ($url)"
        rm -f $temp_file
        return false
    }

    try {
        nu $temp_file
        rm -f $temp_file
        true
    } catch {
        warn $"Cannot source ($url)"
        rm -f $temp_file
        false
    }
}

export def sh-curl [url: string]: nothing -> bool {
    slog $"Executing code from ($url)"
    let temp_file = (mktemp)

    if not (download-to $url $temp_file) {
        warn $"Failed to download ($url)"
        rm -f $temp_file
        return false
    }

    try {
        bash $temp_file
        rm -f $temp_file
        true
    } catch {
        warn $"Failed to execute ($url)"
        rm -f $temp_file
        false
    }
}

export def pkgx-install []: nothing -> bool {
    if ("~/.local/bin/pkgx" | path exists) {
        return true
    }

    if (has-cmd brew) {
        brew install pkgx
        return true
    }

    let platform = (uname).kernel-name
    let arch = (uname).machine
    let url = $"https://pkgx.sh/($platform)/($arch).tgz"

    try {
        if (has-cmd curl) {
            curl -fsSL $url | tar xz -C ~/.local/bin
        } else if (has-cmd wget) {
            wget -qO- $url | tar xz -C ~/.local/bin
        } else {
            warn "curl or wget not installed, skipping pkgx installation"
            return false
        }
        cmd-check pkgx
        true
    } catch {
        false
    }
}

export def dotfiles-install []: nothing -> bool {
    if not (has-cmd git) {
        warn "Using pkgx to install git for dotfiles"
        pkgx-install
        if ("~/.local/bin/pkgx" | path exists) {
            # Note: pkgx activation would need to be handled differently in nushell
        }
    }

    if not (has-cmd git) {
        die "git not installed, cannot clone dotfiles repository"
    }

    slog $"Cloning dotfiles to ($env.DOT_DIR)"
    clone-update "https://github.com/pervezfunctor/dotfiles.git" $env.DOT_DIR
}

export def is-root-user []: nothing -> bool {
    (id -u | into int) == 0
}

export def is-snap-working []: nothing -> bool {
    (has-cmd snap) and (systemctl is-active snapd.service | complete | get exit_code | $in == 0)
}

export def default-shell []: nothing -> string {
    (getent passwd $env.USER | split row ":" | last) | path basename
}

export def get-current-shell []: nothing -> string {
    ps | where pid == $nu.pid | get name | first
}

export def set-zsh-as-default []: nothing -> nothing {
    slog "Setting zsh as default shell"
    chsh -s (which zsh | first)
}

export def get-hostname []: nothing -> string {
    if (has-cmd hostnamectl) {
        hostnamectl hostname
    } else if (has-cmd hostname) {
        hostname
    } else if (has-cmd uname) {
        (uname).nodename
    } else {
        open /etc/hostname
    }
}

export def pre-dir-check [...dirs: string]: nothing -> nothing {
    for dir in $dirs {
        if not (dir-exists $dir) {
            die $"($dir) does not exist, quitting"
        }
    }
}

export def dir-check [...dirs: string]: nothing -> nothing {
    for dir in $dirs {
        if not (dir-exists $dir) {
            warn $"($dir) does not exist"
        }
    }
}

export def cmd-check [...cmds: string]: nothing -> nothing {
    for cmd in $cmds {
        if not (has-cmd $cmd) {
            warn $"($cmd) not installed"
        }
    }
}

export def file-check [...files: string]: nothing -> nothing {
    for file in $files {
        if not ($file | path exists) {
            warn $"($file) does not exist"
        }
    }
}

export def ln-check [target: string, link: string]: nothing -> nothing {
    if not (ln-to-exists $target $link) {
        warn $"($link) not a link to ($target)"
    }
}

export def is-pkg-available [package: string]: nothing -> bool {
    if (has-cmd dpkg) {
        dpkg -l $package | complete | get exit_code | $in == 0
    } else if (has-cmd rpm) {
        rpm -q $package | complete | get exit_code | $in == 0
    } else if (has-cmd pacman) {
        pacman -Qi $package | complete | get exit_code | $in == 0
    } else if (has-cmd apk) {
        apk info -e $package | complete | get exit_code | $in == 0
    } else {
        false
    }
}

export def die [message: string]: nothing -> nothing {
    fail $message
    sleep 3sec
    exit 1
}

export def environs []: nothing -> nothing {
    smd ~/.config
    smd ~/.local/bin
    smd ~/bin
    smd ~/.bin

    if not ((is-distrobox) or (is-toolbox)) {
        smd $env.BOXES_DIR
    }

    $env.GOPATH = $"($env.HOME)/go"
    $env.VOLTA_HOME = $"($env.HOME)/.volta"

    spath-export-unsafe $"($env.VOLTA_HOME)/bin"
    spath-export-unsafe $"($env.HOME)/Applications:($env.GOPATH)/bin:($env.HOME)/.pixi/bin"
    spath-export-unsafe "/usr/bin:/snap/bin:/usr/local/go/bin:($env.HOME)/bin"
    spath-export-unsafe $"($env.HOME)/.local/bin:($env.HOME)/bin:($env.HOME)/.bin"
    spath-export-unsafe $"($env.HOME)/.local/opt/brew/bin:/home/linuxbrew/.linuxbrew/bin"
    spath-export-unsafe $"($env.XDG_CONFIG_HOME)/emacs/bin:($env.HOME)/.local/share/pypoetry"
    spath-export-unsafe $"($env.DOT_DIR)/bin:($env.DOT_DIR)/bin/vt"

    $env.HOMEBREW_NO_ENV_HINTS = 1
    $env.HOMEBREW_NO_BOTTLE_SOURCE_FALLBACK = 1
    $env.HOMEBREW_NO_AUTO_UPDATE = 1

    eval-brew

    if ("~/.local/bin/mise" | path exists) {
        # Note: mise activation for nushell would need different handling
    }
}

export def eval-brew []: nothing -> bool {
    if ("/opt/homebrew/bin/brew" | path exists) {
        ^/opt/homebrew/bin/brew shellenv | parse -r 'export (?<key>\w+)="(?<value>[^"]+)"' | reduce -f {} { |it, acc| $acc | upsert $it.key $it.value } | load-env
        return true
    } else if ("/home/linuxbrew/.linuxbrew/bin/brew" | path exists) {
        ^/home/linuxbrew/.linuxbrew/bin/brew shellenv | parse -r 'export (?<key>\w+)="(?<value>[^"]+)"' | reduce -f {} { |it, acc| $acc | upsert $it.key $it.value } | load-env
        return true
    }
    false
}

export def marker-file-create [marker?: string]: nothing -> nothing {
    let marker_path = $marker | default ($env.HOME | path join ".ilm" ".markers" $"($env.CURRENT_FILE | path basename).marker")

    if ($marker_path | path exists) {
        warn "This script was already run"
    } else {
        sudo mkdir -p ($marker_path | path dirname)
        sudo touch $marker_path
    }
}

export def keep-sudo-running []: nothing -> nothing {
    if not (has-cmd sudo) {
        die "sudo command not found."
    }

    try {
        sudo -v
    } catch {
        die "Failed to validate sudo credentials. Please run sudo manually once or check password."
    }

    slog "Sudo credentials active."

    try {
        while true {
            sudo -n true
            sleep 60sec
        }
    } catch {
        # Process ends when sudo expires
    }
}
