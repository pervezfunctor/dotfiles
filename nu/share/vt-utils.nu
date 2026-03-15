#!/usr/bin/env nu

use utils.nu

# Check if a network service is listening (via ss)
export def is-net-service-running [service: string = "ssh"]: nothing -> bool {
    if not (has-cmd ss) {
        fail "ss command not found. Please install it first."
        return false
    }

    let result = (do { ^sudo ss -tlnp } | complete)
    if $result.exit_code != 0 {
        return false
    }
    $result.stdout | str contains $service
}

# Return true if tmux is available, false otherwise
export def check-tmux []: nothing -> bool {
    if not (has-cmd tmux) {
        fail "tmux is not installed. Please install it first."
        return false
    }
    true
}

# Map a distro name to its conventional default SSH username
export def default-username [distro: string]: nothing -> string {
    let d = ($distro | str downcase)
    if ($d | str starts-with "ubuntu") { return "ubuntu" }
    if ($d | str starts-with "fedora") { return "fedora" }
    if ($d | str starts-with "centos") { return "centos" }
    if ($d | str starts-with "debian") { return "debian" }
    if ($d | str starts-with "arch") { return "arch" }
    if ($d | str starts-with "alpine") { return "alpine" }
    if ($d | str starts-with "nix") { return "nixos" }
    if ($d | str starts-with "rocky") { return "rocky" }
    if (($d | str starts-with "tumbleweed") or ($d | str starts-with "tw")) { return "opensuse" }
    $env.USER
}

# Get the network interface used for the default route
export def get-host-nic []: nothing -> string {
    ^ip route show default
        | lines
        | where { |l| $l | str contains "default" }
        | first
        | split words
        | get 4
}

# Run a command and return its trimmed stdout, or empty string if unavailable/failed
export def try-value [cmd: string, ...args: string]: nothing -> string {
    if not (has-cmd $cmd) {
        return ""
    }

    let result = (do { ^$cmd ...$args } | complete)
    if $result.exit_code != 0 {
        return ""
    }

    $result.stdout | str trim
}

# Generate a password for a VM using pass, pwgen, or openssl
export def generate-password-for [vt_name: string]: nothing -> string {
    let host = (get-hostname)

    let p = (try-value pass generate $"($host)/($vt_name)" 12)
    if ($p | is-not-empty) { return $p }

    let p = (try-value pwgen 12 1)
    if ($p | is-not-empty) { return $p }

    # Use a list to avoid nushell parsing -base64 as a flag for try-value
    let openssl_args = ["rand", "-base64", "12"]
    let p = (try-value openssl ...$openssl_args)
    if ($p | is-not-empty) { return $p }

    ""
}

# Hash a password using SHA-512 crypt via openssl
export def hash-password-for [password: string]: nothing -> string {
    ^openssl passwd -6 $password | str trim
}

# Validate that a password is non-empty and at least 8 characters
export def validate-password [password: string]: nothing -> bool {
    if ($password | is-empty) {
        fail "Password cannot be empty"
        return false
    }

    if ($password | str length) < 8 {
        fail "Password must be at least 8 characters"
        return false
    }

    true
}

# Poll a closure until it returns true or the timeout is exceeded.
# Shows a simple animated "Waiting..." indicator on stderr.
export def wait-until [
    timeout: int    # max seconds to wait
    interval: int   # seconds between attempts
    cmd: closure    # (): bool -- condition to test
]: nothing -> bool {
    let max_attempts = ($timeout // $interval)

    print -e ""

    for count in 0..<$max_attempts {
        if (do $cmd) {
            print -e "\r\e[K"
            return true
        }

        let dots = (0..<(($count mod 3) + 1) | each { "." } | str join)
        print -en $"\rWaiting($dots)"
        sleep (1sec * $interval)
    }

    print -e "\r\e[K"
    false
}

# Optionally prompt the user; return false only when --ask is set and user answers 'n'
export def handle-ask [
    message: string
    --ask
]: nothing -> bool {
    if $ask {
        let response = (input $"\u{1F50D} ($message)? (Y/n): " | str trim | str downcase)
        if $response == "n" {
            return false
        }
    }
    true
}

# Wait for a VM to start and acquire an IP address.
#
# Closures receive the vm_name as their sole argument:
#   exists_fn  : (string) -> bool   -- instance exists
#   running_fn : (string) -> bool   -- instance is running
#   ip_fn      : (string) -> string -- returns IP or empty string on failure
export def wait-for-ip [
    vm_name: string
    exists_fn: closure
    running_fn: closure
    ip_fn: closure
    --ask
]: nothing -> bool {
    if $ask {
        let response = (input "Wait to get IP address? (Y/n): " | str trim | str downcase)
        if $response == "n" {
            return false
        }
    }

    if not (do $exists_fn $vm_name) {
        return false
    }

    if not (wait-until 60 3 { do $running_fn $vm_name }) {
        fail "Instance did not start in time"
        return false
    }

    let ip_result = (wait-until 120 3 {
        let ip = (do $ip_fn $vm_name)
        not ($ip | is-empty)
    })

    if not $ip_result {
        fail "Instance did not get IP address in time"
        return false
    }

    let ip = (do $ip_fn $vm_name)
    slog $"Instance has IP address: ($ip)"
    true
}

# Produce a stable N-digit decimal hash of an arbitrary string
export def stable-hash [
    input: string
    digits: int = 3
]: nothing -> string {
    let mod = (10 ** $digits)
    let digest = ($input | ^sha256sum | str trim | split words | first)
    let hex_part = ($digest | str substring 0..7)
    let decimal = ($"0x($hex_part)" | into int)
    let hash_val = ($decimal mod $mod)
    $hash_val | fill -a r -c '0' -w $digits
}

# Dispatch a command to multiple items, prompting with fzf when no items are given.
#
# Note: nushell cannot build function names at runtime, so callers pass closures
# rather than backend/cmd name strings (as in the bash original).
#
#   list_fn : () -> list<string>        -- enumerate available items
#   handler : (string) -> nothing       -- execute the action on one item
export def handle-multiple-arguments [
    list_fn: closure
    handler: closure
    ...items: string
]: nothing -> nothing {
    let actual_items = if ($items | is-empty) {
        let available = (do $list_fn)

        if ($available | is-empty) {
            slog "No items found."
            return
        }

        let selected = (select-multi "Select items:" ...$available)
        if ($selected | is-empty) {
            slog "Nothing selected."
            return
        }
        $selected
    } else {
        $items
    }

    for item in $actual_items {
        do $handler $item
    }
}

# Dispatch a command to a single item, prompting with fzf when no item is given.
#
#   list_fn : () -> list<string>        -- enumerate available items
#   handler : (string) -> nothing       -- execute the action on the item
export def handle-one-argument [
    list_fn: closure
    handler: closure
    item?: string
]: nothing -> nothing {
    let actual_item = ($item | default "")

    let actual_item = if ($actual_item | is-empty) {
        let available = (do $list_fn)

        if ($available | is-empty) {
            slog "No items found."
            return
        }

        let selected = (select-one "Select item:" ...$available)
        if ($selected | is-empty) {
            slog "Nothing selected."
            return
        }
        $selected
    } else {
        $actual_item
    }

    do $handler $actual_item
}

# Interactively select one or more distributions via fzf
export def select-distributions [...distributions: string]: nothing -> list<string> {
    select-multi "Select distributions to create:" ...$distributions
}

# Create VMs for a list of distros by calling `command distro` for each.
# Logs success/failure counts when done.
#
#   command : (string) -> bool   -- receives the distro name, returns true on success
export def create-all-vt [
    command: closure
    distros: list<string>
]: nothing -> nothing {
    let total = ($distros | length)
    slog $"Starting creation of ($total) VMs..."
    mut failed = 0

    for distro in $distros {
        if not (do $command $distro) {
            fail $"VM creation for ($distro) failed"
            $failed += 1
        }
        sleep 2sec
    }

    if $failed == 0 {
        success "All VMs created successfully!"
    } else {
        info $"Total VMs attempted: ($total)"
        info $"Successfully created: ($total - $failed)"
        info $"Failed: ($failed)"
    }
}

# SSH into a host without host-key checking (for ephemeral/test VMs)
export def sshn [
    host: string
    port: int
    user: string
    connect_timeout: int = 15
]: nothing -> nothing {
    let ssh_args = [
        "-o", "StrictHostKeyChecking=no",
        "-o", "UserKnownHostsFile=/dev/null",
        "-o", $"ConnectTimeout=($connect_timeout)",
        "-o", "ConnectionAttempts=1",
        "-o", "LogLevel=ERROR",
        $"($user)@($host)",
        "-p", ($port | into string)
    ]
    exec ssh ...$ssh_args
}

# Validate a cloud-init YAML file using cloud-init or yamllint
export def validate-cloud-init-yaml [yaml_file: string]: nothing -> bool {
    if not ($yaml_file | path exists) {
        fail $"YAML file ($yaml_file) does not exist"
        return false
    }

    if (has-cmd cloud-init) {
        let result = (do { ^cloud-init devel schema --config-file $yaml_file } | complete)
        return ($result.exit_code == 0)
    }

    if (has-cmd yamllint) {
        let result = (do { ^yamllint $yaml_file } | complete)
        return ($result.exit_code == 0)
    }

    fail "No cloud-init validator found. Please install cloud-init or yamllint."
    false
}
