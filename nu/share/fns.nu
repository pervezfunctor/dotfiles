#! /usr/bin/env nu

use utils.nu

# ============================================
# Font Management
# ============================================

export def font-names []: nothing -> list<string> {
    if not (has-cmd fc-list) {
        warn "fc-list not installed, cannot list fonts"
        return []
    }

    ^fc-list : family | lines | split column ":" | get column2? | where { |x| $x != "" } | each { str trim } | sort | uniq
}

# ============================================
# Git Helpers
# ============================================

export def git-checkout-previous-file [file: string]: nothing -> bool {
    if not (has-cmd git) {
        warn "git not installed, cannot checkout previous file version"
        return false
    }

    if ($file | is-empty) {
        fail "Usage: git-checkout-previous-file <file>"
        return false
    }

    let prev_commit = (git log --format=%H -- $file | lines | get 1?)
    if ($prev_commit | is-empty) {
        fail $"No previous commit found for ($file)"
        return false
    }

    git checkout $prev_commit -- $file
    true
}

export def safe-push [...args: string]: nothing -> bool {
    git stash -u
    let push_result = (do { git push ...$args } | complete)
    git stash pop
    $push_result.exit_code == 0
}

# ============================================
# System Queries
# ============================================

export def osquery-update-db []: nothing -> nothing {
    if not (has-cmd osinfo-db-import) {
        warn "osinfo-db-import not installed, cannot update osquery database"
        return
    }
    sudo osinfo-db-import --system --latest
}

# ============================================
# Terminal Session
# ============================================

export def one-shell-tmux []: nothing -> nothing {
    let tmux_session = "default"

    if (($env.TMUX? | is-not-empty) or ($env.EMACS? | is-not-empty)
        or ($env.INSIDE_EMACS? | is-not-empty) or ($env.VIM? | is-not-empty)
        or ($env.VSCODE_RESOLVING_ENVIRONMENT? | is-not-empty)
        or ($env.TERM_PROGRAM? | default "") == "vscode") {
        return
    }

    ^tmux start-server

    let has_session = (do { ^tmux has-session -t $tmux_session } | complete | get exit_code) == 0
    if not $has_session {
        ^tmux new-session -d -s $tmux_session
    }

    exec ^tmux attach-session -t $tmux_session
}

# ============================================
# Development Tools
# ============================================

export def nvim-update []: nothing -> nothing {
    if (has-cmd nvim) {
        nvim --headless "+Lazy! sync" +qa
    } else {
        warn "nvim not available, skipping nvim extensions update."
    }
}

export def system-update []: nothing -> nothing {
    if (has-cmd sup) {
        sup
    }

    if (has-cmd flatpak) {
        flatpak update --user -y
        flatpak update -y
    }

    if (has-cmd snap) { snap refresh }
    if (has-cmd brew) { brew upgrade }
    if (has-cmd mise) {
        mise self-update
        mise upgrade --bump
    }
    if (has-cmd pixi) { pixi global update }

    if (dir-exists $env.DOT_DIR) {
        cd $env.DOT_DIR
        git-up
    }
}

# ============================================
# System Maintenance
# ============================================

export def remove-keyrings []: nothing -> nothing {
    sudo rm -rf /run/user/1000/keyrings/*
    trash .local/share/keyrings/*
}

export def partitions []: nothing -> nothing {
    ^lsblk -f -o NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL,UUID | lines | where { |line| not ($line | str contains "/snap/") } | print
    let count = (^lsblk -f | lines | where { |line| not ($line | str contains "/snap/") } | where { |line| $line =~ '^[a-z]' } | length)
    print $"Total block devices (excluding snaps): ($count)"
}

export def subvolumes []: nothing -> nothing {
    let btrfs_mounts = (^mount | lines | where { |line| $line =~ "type btrfs" } | parse "{device} on {mount_point} type btrfs {options}" | get mount_point? | uniq)

    if ($btrfs_mounts | is-empty) {
        print "No Btrfs filesystems found."
        return
    }

    for mount_point in $btrfs_mounts {
        print $"Btrfs filesystem: ($mount_point)"
        print "----------------------------------------"
        let result = (do { sudo btrfs subvolume list -p -t $mount_point } | complete)
        if $result.exit_code != 0 {
            print $"Unable to list subvolumes for ($mount_point)"
        } else {
            print $result.stdout
        }
    }

    print ""
    print $"Btrfs filesystems: ($btrfs_mounts | length)"
}

# ============================================
# File Operations
# ============================================

export def sync-folders [
    source: string
    destination: string
    --delete
    --dry-run
]: nothing -> bool {
    if not (has-cmd rsync) {
        warn "rsync not installed, skipping sync"
        return false
    }

    if not (dir-exists $source) {
        fail $"Source directory ($source) does not exist"
        return false
    }

    if not (dir-exists $destination) {
        fail $"Destination directory ($destination) does not exist"
        return false
    }

    slog $"Syncing ($source) to ($destination)"
    let delete_flag = if $delete { "--delete" } else { "" }
    let dry_flag = if $dry_run { "--dry-run" } else { "" }

    rsync -avh $delete_flag $dry_flag $"($source)/" $"($destination)/"
}

export def syslogs []: nothing -> nothing {
    sudo journalctl -b -p 3 -xn
}

# ============================================
# Directory Validation
# ============================================

export def dirs-exist [...dirs: string]: nothing -> bool {
    let failed = ($dirs | where { |dir| not (dir-exists $dir) })

    if ($failed | length) > 0 {
        fail $"Missing required directories: ($failed | str join ' ')"
        return false
    }
    true
}

export def check-dirs [...dirs: string]: nothing -> nothing {
    if not (dirs-exist ...$dirs) {
        die "Missing required directories, quitting"
    }
}

# ============================================
# Btrfs/Nix Mount Setup
# ============================================

export def create-ublue-nix-mount [
    subvol_path: string = "/home/@nix"
    mount_point: string = "/nix"
]: nothing -> bool {
    let parent_dir = ($subvol_path | path dirname)

    if not (commands-available findmnt btrfs systemd-escape systemctl) {
        return false
    }
    if not (dirs-exist $parent_dir $mount_point) {
        return false
    }

    let parent_fstype = (^findmnt -nro FSTYPE $parent_dir | str trim)
    if ($parent_fstype | is-empty) {
        fail $"cannot determine filesystem for ($parent_dir)"
        return false
    }

    if $parent_fstype != "btrfs" {
        fail $"($parent_dir) is not on a Btrfs filesystem"
        return false
    }

    let device = (^findmnt -nro SOURCE $parent_dir | str trim)
    if ($device | is-empty) {
        fail $"cannot resolve backing device for ($parent_dir)"
        return false
    }

    let subvol_exists = (do { sudo btrfs subvolume show $subvol_path } | complete | get exit_code) == 0
    if not $subvol_exists {
        let exists = (do { sudo test -e $subvol_path } | complete | get exit_code) == 0
        if $exists {
            fail $"($subvol_path) exists but is not a Btrfs subvolume"
            return false
        }
        let create_result = (do { sudo btrfs subvolume create $subvol_path } | complete)
        if $create_result.exit_code != 0 {
            fail $"failed to create subvolume at ($subvol_path)"
            return false
        }
    }

    let subvol_id = (sudo btrfs subvolume show $subvol_path | lines | where { |line| $line =~ "Subvolume ID" } | first | split column ":" | get column2? | first? | str trim)
    if ($subvol_id | is-empty) {
        fail $"unable to read subvolume ID for ($subvol_path)"
        return false
    }

    let mount_active = 0
    let mount_exists = (^findmnt -rn --target $mount_point | complete | get exit_code) == 0

    if $mount_exists {
        let current_device = (^findmnt -rn -o SOURCE $mount_point | str trim)
        let current_options = (^findmnt -rn -o OPTIONS $mount_point | str trim)
        let current_subvolid = ($current_options | split row "," | where { |opt| $opt =~ "^subvolid=" } | first? | split row "=" | get 1?)

        if $current_device == $device and $current_subvolid == $subvol_id {
            true
        } else {
            fail $"($mount_point) already mounted (device=($current_device) subvolid=($current_subvolid | default 'unknown')); refusing to change it"
            return false
        }
    } else {
        let mount_result = (do { sudo mount -t btrfs -o $"subvolid=($subvol_id)" $device $mount_point } | complete)
        if $mount_result.exit_code != 0 {
            fail $"failed to mount ($device) subvolid=($subvol_id) at ($mount_point)"
            return false
        }
    }

    let unit_name = (^systemd-escape --path --suffix=mount $mount_point | str trim)
    mut what_source = $device

    if not ($what_source | str starts-with "UUID=") {
        if (has-cmd blkid) {
            let uuid = (sudo blkid -s UUID -o value $device | str trim)
            if ($uuid | is-not-empty) {
                $what_source = $"UUID=($uuid)"
            }
        }
    }

    let mount_options = $"subvolid=($subvol_id)"
    let unit_description = $"Mount ($mount_point) (subvolid ($subvol_id))"
    let unit_content = $"[Unit]
Description=($unit_description)
After=local-fs.target

[Mount]
What=($what_source)
Where=($mount_point)
Type=btrfs
Options=($mount_options)

[Install]
WantedBy=local-fs.target"

    let unit_path = $"/etc/systemd/system/($unit_name)"
    let tmp_unit = (mktemp | str trim)

    echo $unit_content | save -f $tmp_unit
    sudo install -m 0644 -D $tmp_unit $unit_path
    rm -f $tmp_unit

    sudo systemctl daemon-reload
    sudo systemctl enable --now $unit_name
    true
}

# ============================================
# Selection Helpers
# ============================================

export def select-one [
    prompt: string = "Select > "
    ...items: string
]: nothing -> string {
    if not (has-cmd fzf) {
        return ""
    }

    if ($items | is-empty) {
        return ""
    }

    $items | str join "\n" | fzf --prompt=$prompt --height=40% --reverse
}

# ============================================
# Virtual Machine SSH
# ============================================

export def vme-ssh []: nothing -> nothing {
    if not (has-cmd vme) {
        fail "vme command not found in PATH"
        return
    }

    let vms = (^vme list | complete | get stdout | lines | skip 2 | where { |line| not ($line =~ '^[-\s]*$') } | parse -r '\s+\S+\s+(\S+)' | get capture0?)

    if ($vms | is-empty) {
        warn "no virtual machines found"
        return
    }

    let selected = (select-one 'VM > ' ...$vms)
    if ($selected | is-empty) {
        warn "selection cancelled"
        return
    }

    ^vme ssh $selected
}

# ============================================
# Rsync Shortcuts
# ============================================

export def rcp [...args: string]: nothing -> nothing {
    rsync --archive -hh --partial --info=stats1,progress2 --modify-window=1 ...$args
}

export def rmv [...args: string]: nothing -> nothing {
    rsync --archive -hh --partial --info=stats1,progress2 --modify-window=1 --remove-source-files ...$args
}

# ============================================
# SSH Helpers
# ============================================

export def sshl []: nothing -> nothing {
    let ssh_dir = ($env.HOME | path join ".ssh")
    let config_dirs = [($ssh_dir | path join "config"), ($ssh_dir | path join "conf.d")]

    let host = (config_dirs | where { |d| $d | path exists } | each { |dir|
        if ($dir | path type) == "dir" {
            glob $"($dir)/*"
        } else {
            [$dir]
        }
    } | flatten | where { |f| $f | path exists } | each { |file|
        open $file | lines | where { |line| $line =~ '^Host\s+' } | each { |line|
            $line | str replace -r '^Host\s+' '' | str trim | split row " " | where { |h| $h != "*" }
        } | flatten
    } | flatten | sort | uniq | str join "\n" | fzf --prompt="SSH Host: ")

    if ($host | is-not-empty) {
        ssh $host
    }
}

# ============================================
# Display Manager Setup
# ============================================

export def greetd-setup [wm: string = "Hyprland"]: nothing -> nothing {
    si greetd tuigreet dbus-user-session
    sudo systemctl enable greetd
    sudo systemctl start seatd
    sudo usermod -aG seatd $env.USER

    slog "Installing greetd"
    si greetd
    slog "greetd installation done!"

    cmd-check greetd

    let config = $"[terminal]
vt = 1

[default_session]
command = \"tuigreet --time --remember --cmd ($wm)\"
user = \"greeter\""

    echo $config | sudo tee /etc/greetd/config.toml
}

# ============================================
# GitHub Auth
# ============================================

export def gh-auth []: nothing -> nothing {
    gh auth login --hostname github.com --git-protocol https
}

export def gh-nobrowser []: nothing -> nothing {
    with-env { BROWSER: false } { gh auth login }
}

# ============================================
# Dependency Checkers
# ============================================


