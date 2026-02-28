#! /usr/bin/env nu

use utils.nu

# ============================================
# SSH Configuration Management
# ============================================

export def ssh-config-list [
    --config-file: string = "~/.ssh/config"
]: nothing -> list<string> {
    let cfg = ($config_file | path expand)
    if not ($cfg | path exists) {
        return []
    }

    open $cfg | lines | where { $in =~ '^Host\s+' } | each { |line|
        $line | parse -r '^Host\s+(\S+)' | get capture0 | first
    }
}

export def ssh-config-add [
    host: string
    --hostname: string
    --user: string
    --port: int = 22
    --identity: string = ""
    --config-file: string = "~/.ssh/config"
]: nothing -> nothing {
    let cfg = ($config_file | path expand)
    let host_file = ($cfg | path dirname | path join "conf.d" $"($host).conf")

    if not ($cfg | path dirname | path exists) {
        mkdir ($cfg | path dirname)
    }

    if not ($cfg | path exists) {
        touch $cfg
        chmod 600 $cfg
    }

    let include_line = "Include ~/.ssh/conf.d/*.conf"
    let content = (open $cfg)
    if not ($content | str contains $include_line) {
        $include_line | save --append $cfg
    }

    if (ssh-host-exists $host --config-file $cfg) {
        slog $"Host '($host)' already exists. Skipping."
        return
    }

    if not ($host_file | path dirname | path exists) {
        mkdir ($host_file | path dirname)
        chmod 700 ($host_file | path dirname)
    }

    let lines = [
        $"Host ($host)"
        $"    HostName ($hostname)"
        $"    User ($user)"
        $"    Port ($port)"
        "    IdentitiesOnly yes"
    ]

    let lines = if ($identity | is-not-empty) {
        $lines | append $"    IdentityFile ($identity)"
    } else {
        $lines
    }

    $lines | str join "\n" | save $host_file
    chmod 600 $host_file

    slog $"Added host '($host)' to ($host_file)."
}

export def ssh-config-remove [
    host: string
    --config-file: string = "~/.ssh/config"
]: nothing -> nothing {
    let cfg = ($config_file | path expand)
    let host_file = ($cfg | path dirname | path join "conf.d" $"($host).conf")

    if ($host_file | path exists) {
        rm $host_file
        slog $"Removed host '($host)' by deleting ($host_file)."
        return
    }

    if not (ssh-host-exists $host --config-file $cfg) {
        slog $"Host '($host)' not found. Skipping."
        return
    }

    let lines = (open $cfg | lines)
    let result = (ssh-remove-host-block $lines $host)

    $result | str join "\n" | save -f $cfg
    slog $"Removed host '($host)' from ($cfg)."
}

def ssh-remove-host-block [lines: list<string>, host: string]: nothing -> list<string> {
    $lines | reduce --fold {skip: false, result: []} { |line, acc|
        let trimmed = ($line | str trim)
        if $trimmed == $"Host ($host)" {
            {skip: true, result: $acc.result}
        } else if ($trimmed | str replace -r '^Host\s+' '' | str trim) != $trimmed {
            {skip: false, result: ($acc.result | append $line)}
        } else if not $acc.skip {
            {skip: false, result: ($acc.result | append $line)}
        } else {
            $acc
        }
    } | get result
}

export def ssh-host-exists [
    host: string
    --config-file: string = "~/.ssh/config"
]: nothing -> bool {
    let cfg = ($config_file | path expand)
    if not ($cfg | path exists) {
        return false
    }

    let conf_d = ($cfg | path dirname | path join "conf.d")
    let files = if ($conf_d | path exists) {
        (glob $"($conf_d)/*.conf") | append $cfg
    } else {
        [$cfg]
    }

    for file in $files {
        let content = (open $file)
        if ($content | str contains $"Host ($host)") {
            return true
        }
    }

    false
}


export def ssh-server-setup []: nothing -> nothing {
    let pkg_info = (detect-ssh-packages)

    if not (has-cmd sshd) {
        slog "SSH server is not installed. Installing now..."
        if $pkg_info.manager == "pacman" {
            ^$pkg_info.manager -S --noconfirm openssh
        } else {
            ^$pkg_info.manager install -y openssh-server
        }
    }

    ssh-configure-password-auth
    ssh-configure-port 2222
    ssh-disable-root-login

    slog "Starting SSH service..."
    ^systemctl enable --now $pkg_info.service

    success "SSH server is now running with password authentication on port 2222."
}

def detect-ssh-packages []: nothing -> record<manager: string, service: string> {
    if (has-cmd apt-get) {
        {manager: "apt-get", service: "ssh"}
    } else if (has-cmd dnf) {
        {manager: "dnf", service: "sshd"}
    } else if (has-cmd pacman) {
        {manager: "pacman", service: "sshd"}
    } else if (has-cmd zypper) {
        {manager: "zypper", service: "sshd"}
    } else {
        fail "Unsupported system"
        {manager: "", service: ""}
    }
}

export def ssh-configure-password-auth []: nothing -> nothing {
    let sshd_config = "/etc/ssh/sshd_config"
    let backup = $"/etc/ssh/sshd_config.bak.(date now | format date "%F-%H%M%S")"

    slog $"Backing up ($sshd_config) to ($backup)"
    ^sudo cp -a $sshd_config $backup
    ^sudo chmod u+w $sshd_config

    let content = (open $sshd_config)
    let new_content = if ($content | str contains "PasswordAuthentication") {
        $content | str replace -r '(?m)^[#\s]*PasswordAuthentication.*' 'PasswordAuthentication yes'
    } else {
        $content + "\nPasswordAuthentication yes"
    }

    let new_content = if ($new_content | str contains "ChallengeResponseAuthentication") {
        $new_content | str replace -r '(?m)^[#\s]*ChallengeResponseAuthentication.*' 'ChallengeResponseAuthentication no'
    } else {
        $new_content + "\nChallengeResponseAuthentication no"
    }

    echo $new_content | ^sudo tee $sshd_config out> /dev/null
    ^sudo chmod 644 $sshd_config

    ssh-restart-service
    success "Password authentication has been enabled."
}

export def ssh-password-enable-file [
    port: int = 2222
]: nothing -> nothing {
    if (id -u) != "0" {
        fail "This command must be run as root"
        return
    }

    let conf_d = "/etc/ssh/sshd_config.d"
    ^mkdir -p $conf_d

    let file = $"($conf_d)/99-password.conf"
    let tmp = (mktemp -t)

    let lines = [
        $"Port ($port)"
        "PermitRootLogin no"
        "PasswordAuthentication yes"
        "PubkeyAuthentication yes"
    ]

    $lines | str join "\n" | save -f $tmp

    let current = if ($file | path exists) { open $file } else { "" }
    let new_content = (open $tmp)

    if $current != $new_content {
        ^sudo cp -f $tmp $file
    }

    rm -f $tmp
}

export def ssh-configure-port [
    port: int = 2222
]: nothing -> nothing {
    let sshd_config = "/etc/ssh/sshd_config"
    let content = (open $sshd_config)

    let new_content = if ($content =~ '(?m)^#?Port\s+') {
        $content | str replace -r '(?m)^#?Port\s+\d+' $"Port ($port)"
    } else {
        $content + $"\nPort ($port)"
    }

    echo $new_content | ^sudo tee $sshd_config out> /dev/null
    slog $"Changed SSH port to ($port)."
}

export def ssh-disable-root-login []: nothing -> nothing {
    let sshd_config = "/etc/ssh/sshd_config"
    let content = (open $sshd_config)

    let new_content = if ($content =~ '(?m)^#?PermitRootLogin\s+') {
        $content | str replace -r '(?m)^#?PermitRootLogin\s+\S+' 'PermitRootLogin no'
    } else {
        $content + "\nPermitRootLogin no"
    }

    echo $new_content | ^sudo tee $sshd_config out> /dev/null
    slog "Disabled root SSH login."
}

export def ssh-restart-service []: nothing -> nothing {
    let services = [sshd ssh]
    for svc in $services {
        if (^systemctl list-unit-files | grep -q $"^($svc).") {
            ^sudo systemctl restart $svc
            return
        }
    }
    warn "Could not restart SSH service."
}

# ============================================
# SSH Hardening
# ============================================

export def ssh-harden []: nothing -> nothing {
    if (id -u) != "0" {
        fail "This command must be run as root"
        return
    }

    let conf_d = "/etc/ssh/sshd_config.d"
    ^sudo mkdir -p $conf_d

    let hardening_file = $"($conf_d)/99-hardening.conf"

    let config = [
        "# Enforce modern SSH security settings"
        "Protocol 2"
        "PermitRootLogin no"
        "PasswordAuthentication no"
        "KbdInteractiveAuthentication no"
        "ChallengeResponseAuthentication no"
        "PermitEmptyPasswords no"
        "UsePAM yes"
        "PubkeyAuthentication yes"
        ""
        "# Optional: reduce attack surface"
        "X11Forwarding no"
        "AllowAgentForwarding no"
        "AllowTcpForwarding no"
        "AllowStreamLocalForwarding no"
        "AllowUsers *"
    ] | str join "\n"

    echo $config | ^sudo tee $hardening_file out> /dev/null
    ssh-restart-service

    success "SSH hardening applied."
}

# ============================================
# VM SSH Setup (for virtualization tools)
# ============================================

export def vm-ssh-setup []: nothing -> nothing {
    if (id -u) != "0" {
        fail "This command must be run as root"
        return
    }

    let os_id = (open /etc/os-release | lines | where { $in =~ '^ID=' } | first | str replace 'ID=' '')

    match $os_id {
        "arch" => { ^pacman -Sy --noconfirm openssh qemu-guest-agent }
        "tumbleweed" | "opensuse" => { ^zypper install -y openssh qemu-guest-agent }
        "ubuntu" | "debian" => {
            ^apt-get update
            ^apt-get install -y openssh-server qemu-guest-agent
        }
        "fedora" => { ^dnf install -y openssh-server qemu-guest-agent }
        "centos" | "rhel" => { ^yum install -y openssh-server qemu-guest-agent }
        _ => { fail $"Unsupported distribution: ($os_id)" }
    }

    ssh-enable-password-file
    ssh-ensure-host-keys

    ^systemctl enable --now sshd out> /dev/null err> /dev/null
    ^systemctl enable --now ssh out> /dev/null err> /dev/null
    ^systemctl enable --now qemu-guest-agent

    ^systemctl restart sshd out> /dev/null err> /dev/null
    ^systemctl restart ssh out> /dev/null err> /dev/null

    success "VM SSH setup complete."
}

export def ssh-enable-password-file []: nothing -> nothing {
    let conf_d = "/etc/ssh/sshd_config.d"
    ^mkdir -p $conf_d

    let file = $"($conf_d)/99-password.conf"
    let tmp = (mktemp -t)

    ["PasswordAuthentication yes" "PubkeyAuthentication yes"] | str join "\n" | save -f $tmp

    let current = if ($file | path exists) { open $file } else { "" }
    let new_content = (open $tmp)

    if $current != $new_content {
        cp -f $tmp $file
    }

    rm -f $tmp
}

export def ssh-ensure-host-keys []: nothing -> nothing {
    let keys = (do { glob "/etc/ssh/ssh_host_*key" } | complete)
    if ($keys.stdout | lines | length) == 0 {
        slog "Generating SSH host keys..."
        ^ssh-keygen -A
    }
}

# ============================================
# Proxmox VM SSH Host Setup
# ============================================

export def vm-host-ssh-setup [
    vmid: int
    --user: string = "root"
    --port: int = 22
]: nothing -> nothing {
    if (id -u) != "0" {
        fail "This command must be run as root"
        return
    }

    if not (has-cmd qm) {
        fail "qm command not found. This must be run on a Proxmox host."
        return
    }

    ssh-ensure-host-keys-local
    vm-push-keys $vmid

    slog "Waiting for VM network..."
    sleep 2sec

    let ip = (vm-get-ip $vmid)
    if ($ip | is-empty) {
        fail "Could not determine VM IP. Check Guest Agent."
        return
    }

    slog $"Detected VM IP: ($ip)"
    slog "Testing SSH access..."

    if (vm-test-ssh $ip $user $port) {
        success "SSH connectivity confirmed."
    } else {
        fail "SSH test failed. Verify SSH service inside the VM."
    }
}

def ssh-ensure-host-keys-local []: nothing -> nothing {
    let dir = "/root/.ssh"
    ^sudo mkdir -p $dir
    ^sudo chmod 700 $dir

    if not ("/root/.ssh/id_ed25519" | path exists) {
        ^sudo ssh-keygen -t ed25519 -f "/root/.ssh/id_ed25519" -N ""
    }

    if not ("/root/.ssh/id_rsa" | path exists) {
        ^sudo ssh-keygen -t rsa -b 4096 -f "/root/.ssh/id_rsa" -N ""
    }

    ^sudo chmod 600 /root/.ssh/id_*
}

def vm-push-keys [vmid: int]: nothing -> nothing {
    let pub_ed = "/root/.ssh/id_ed25519.pub"
    let pub_rsa = "/root/.ssh/id_rsa.pub"

    let auth_keys = [
        (open $pub_ed)
        (open $pub_rsa)
    ] | str join "\n"

    echo $auth_keys | ^qm set $vmid --sshkeys /dev/stdin
}

def vm-get-ip [vmid: int]: nothing -> string {
    let ip = (^qm guest exec $vmid ip -4 addr show 2>/dev/null
        | awk '/inet / {print $2}' | cut -d/ -f1 | head -n1)

    if ($ip | is-empty) {
        ^qm guest info $vmid 2>/dev/null | awk '/ip-addresses/ {flag=1} flag && /"ip-address":/ {gsub(/["\,]/,""); print $2; exit}'
    } else {
        $ip
    }
}

def vm-test-ssh [ip: string, user: string, port: int]: nothing -> bool {
    let result = (^ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p $port $"($user)@($ip)" "echo ok" err> /dev/null)

    $result | str contains "ok"
}


