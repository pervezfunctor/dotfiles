#!/usr/bin/env nu

use utils.nu

# Create a tmux session, or attach if it already exists.
# With --force, kill and recreate if it exists.
export def tmux-session [
    session_name: string
    --force (-f)
]: nothing -> nothing {
    if ($session_name | is-empty) {
        fail "Session name cannot be empty"
        return
    }

    let has_session = (do { ^tmux has-session -t $session_name } | complete)
    if $has_session.exit_code == 0 {
        if $force {
            slog $"Session '($session_name)' exists. Recreating..."
            ^tmux kill-session -t $session_name
        } else {
            slog $"Session '($session_name)' already exists. Attaching..."
            ^tmux attach-session -t $session_name
            return
        }
    }
}

# Attach to an existing tmux session
export def attach-session [
    session_name: string
]: nothing -> nothing {
    if ($session_name | is-empty) {
        fail "Session name cannot be empty"
        return
    }

    let has_session = (do { ^tmux has-session -t $session_name } | complete)
    if $has_session.exit_code != 0 {
        fail $"Session '($session_name)' does not exist"
        return
    }

    slog $"Attaching to session '($session_name)'..."
    ^tmux attach-session -t $session_name
}

# Detach from the current tmux session
export def detach-session []: nothing -> nothing {
    if ($env.TMUX? | default "" | is-empty) {
        fail "Not currently in a tmux session"
        return
    }

    slog "Detaching from tmux session..."
    ^tmux detach-client
}

# Kill a tmux session
export def destroy-session [
    session_name: string
]: nothing -> nothing {
    if ($session_name | is-empty) {
        fail "Session name cannot be empty"
        return
    }

    let has_session = (do { ^tmux has-session -t $session_name } | complete)
    if $has_session.exit_code != 0 {
        warn $"Session '($session_name)' does not exist"
        return
    }

    slog $"Destroying session '($session_name)'..."
    ^tmux kill-session -t $session_name
    success "Session destroyed"
}

# Create a new tmux session with all commands in tiled panes.
# Attaches if session already exists.
export def tmux-grid [
    session_name: string
    ...cmds: string
]: nothing -> nothing {
    if not (has-cmd tmux) {
        fail "tmux is not installed. Please install it first."
        return
    }

    if ($session_name | is-empty) {
        fail "Session name cannot be empty"
        return
    }

    if ($cmds | is-empty) {
        fail "At least one command is required"
        return
    }

    let has_session = (do { ^tmux has-session -t $session_name } | complete)
    if $has_session.exit_code == 0 {
        slog $"Session '($session_name)' already exists. Attaching to it..."
        ^tmux attach-session -t $session_name
        return
    }

    let base_index_result = (do { ^tmux show-options -gqv base-index } | complete)
    let base_index = if ($base_index_result.exit_code == 0 and (not ($base_index_result.stdout | str trim | is-empty))) {
        $base_index_result.stdout | str trim | into int
    } else { 1 }

    let pane_base_result = (do { ^tmux show-options -gqv pane-base-index } | complete)
    let pane_base_index = if ($pane_base_result.exit_code == 0 and (not ($pane_base_result.stdout | str trim | is-empty))) {
        $pane_base_result.stdout | str trim | into int
    } else { 0 }

    let num_cmds = ($cmds | length)
    slog $"Creating new tmux session '($session_name)' for ($num_cmds) command(s)..."

    ^tmux new-session -d -s $session_name -n $"grid-($session_name)"

    for _i in 1..<$num_cmds {
        ^tmux split-window -t $"($session_name):($base_index)"
        ^tmux select-layout -t $"($session_name):($base_index)" tiled
    }

    for i in 0..<$num_cmds {
        let pane_index = ($pane_base_index + $i)
        let target_pane = $"($session_name):($base_index).($pane_index)"
        ^tmux send-keys -t $target_pane ($cmds | get $i) "Enter"
        sleep 100ms
    }

    ^tmux attach-session -t $session_name
}

# Create a tiled pane tmux session from a file of commands (one per line, # = comment)
export def tmux-grid-from-file [
    session_name: string
    file_path: string
]: nothing -> nothing {
    if ($session_name | is-empty) {
        fail "Session name cannot be empty"
        return
    }

    if not ($file_path | path exists) {
        fail $"File '($file_path)' does not exist"
        return
    }

    let cmds = (open $file_path
        | lines
        | where { |l| not ($l | str trim | is-empty) }
        | where { |l| not ($l | str trim | str starts-with "#") }
        | each { |l| $l | str trim })

    if ($cmds | is-empty) {
        fail $"No valid commands found in '($file_path)'"
        return
    }

    tmux-grid $session_name ...$cmds
}

# Create a tmux session with one named window per entry.
# windows: list of records with 'name' and 'cmd' fields
export def tmux-windows [
    session_name: string
    windows: list<record<name: string, cmd: string>>
]: nothing -> nothing {
    if not (has-cmd tmux) {
        fail "tmux is not installed. Please install it first."
        return
    }

    if ($session_name | is-empty) {
        fail "Session name cannot be empty"
        return
    }

    if ($windows | is-empty) {
        fail "At least one window is required"
        return
    }

    let has_session = (do { ^tmux has-session -t $session_name } | complete)
    if $has_session.exit_code == 0 {
        slog $"Session '($session_name)' already exists."
        ^tmux attach-session -t $session_name
        return
    }

    let base_index_result = (do { ^tmux show-options -gqv base-index } | complete)
    let base_index = if ($base_index_result.exit_code == 0 and (not ($base_index_result.stdout | str trim | is-empty))) {
        $base_index_result.stdout | str trim | into int
    } else { 1 }

    let num_windows = ($windows | length)
    slog $"Creating new tmux session '($session_name)' with ($num_windows) window(s)..."

    let first = ($windows | first)
    ^tmux new-session -d -s $session_name -n $first.name
    ^tmux send-keys -t $"($session_name):($base_index)" $first.cmd "Enter"

    for i in 1..<$num_windows {
        let w = ($windows | get $i)
        let window_num = ($base_index + $i)
        ^tmux new-window -t $"($session_name):($window_num)" -n $w.name
        ^tmux send-keys -t $"($session_name):($window_num)" $w.cmd "Enter"
    }

    ^tmux attach-session -t $session_name
}

# Create a named-window tmux session from a file.
# Each non-comment line: <name> <command...>
export def tmux-windows-from-file [
    session_name: string
    file_path: string
]: nothing -> nothing {
    if ($session_name | is-empty) {
        fail "Session name cannot be empty"
        return
    }

    if not ($file_path | path exists) {
        fail $"File '($file_path)' does not exist"
        return
    }

    let windows = (open $file_path
        | lines
        | where { |l| not ($l | str trim | is-empty) }
        | where { |l| not ($l | str trim | str starts-with "#") }
        | each { |l|
            let trimmed = ($l | str trim)
            let words = ($trimmed | split words)
            if ($words | length) >= 2 {
                let name = ($words | first)
                let cmd = ($trimmed | str replace --regex '^\S+\s+' "")
                {name: $name, cmd: $cmd}
            } else {
                {name: "", cmd: ""}
            }
        }
        | where { |w| not ($w.name | is-empty) })

    if ($windows | is-empty) {
        fail $"No valid name-command pairs found in '($file_path)'"
        return
    }

    tmux-windows $session_name $windows
}

# Generate VM/container names by combining distros with a suffix prefix
export def generate-names [
    prefix: string
    ...distros: string
]: nothing -> list<string> {
    $distros | each { |d| $"($d)-($prefix)" }
}

# Build a list of commands by applying a closure to each VM name
export def create-commands-generic [
    create_cmd: closure
    ...vm_names: string
]: nothing -> list<string> {
    $vm_names | each { |name| do $create_cmd $name }
}

# Build commands for distros: generate names (distro-prefix) then apply a closure
export def create-commands [
    prefix: string
    create_cmd: closure
    ...distros: string
]: nothing -> list<string> {
    $distros | each { |d| do $create_cmd $"($d)-($prefix)" }
}

# Start VMs that are not yet running
export def start-sessions [
    exists_fn: closure
    start_fn: closure
    ...names: string
]: nothing -> nothing {
    for d in $names {
        if not (do $exists_fn $d) {
            slog $"'($d)' is not running. Starting it..."
            if not (do $start_fn $d) {
                fail $"Failed to start ($d). Please check its status."
                return
            }
        }
    }
}
