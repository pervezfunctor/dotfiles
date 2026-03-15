#! /usr/bin/env nu

use utils.nu *

export-env {
    $env.DOTFILES_VIEW_LOG_DIR = ($env.ILM_LOG_DIR? | default (($env.XDG_STATE_HOME? | default ($env.HOME | path join ".local" "state")) | path join "dotfiles" "logs"))
}

def levels-for [level: string] {
    match $level {
        "error" => ["error"]
        "fail" => ["fail" "error"]
        "warn" => ["warn" "fail" "error"]
        "success" => ["success" "warn" "fail" "error"]
        "info" => ["info" "success" "warn" "fail" "error"]
        "slog" => ["slog" "info" "success" "warn" "fail" "error"]
        "output" => ["output"]
        "all" => ["slog" "info" "warn" "fail" "success" "output" "error"]
        _ => []
    }
}

def patterns-for [level: string] {
    match $level {
        "slog" => ["slog.log" "*.info.log"]
        "info" => ["info.log" "*.info.log"]
        "warn" => ["warn.log" "*.warn.log"]
        "fail" => ["fail.log" "*.fail.log"]
        "success" => ["success.log" "*.success.log"]
        "output" => ["output.log" ".dotfiles-output.log" "*.stdout.log"]
        "error" => ["error.log" ".dotfiles-error.log" "*.stderr.log"]
        _ => []
    }
}

def colorize [line: string] {
    if ($line | str contains " FAIL ") or ($line | str contains "FAIL ") or ($line | str contains " error ") {
        $"\u001b[1;31m($line)\u001b[0m"
    } else if ($line | str contains " WARN ") or ($line | str contains "WARN ") {
        $"\u001b[1;33m($line)\u001b[0m"
    } else if ($line | str contains " INFO ") or ($line | str contains "INFO ") {
        $"\u001b[1;36m($line)\u001b[0m"
    } else if ($line | str contains " SLOG ") or ($line | str contains "SLOG ") {
        $"\u001b[1;35m($line)\u001b[0m"
    } else if ($line | str contains " OK ") or ($line | str contains "SUCCESS ") {
        $"\u001b[1;32m($line)\u001b[0m"
    } else {
        $line
    }
}

def collect-files [log_dir: string, levels: list<string>] {
    mut files = []

    for lvl in $levels {
        for pattern in (patterns-for $lvl) {
            let found = (glob ($log_dir | path join $pattern))
            if ($found | is-not-empty) {
                $files = ($files ++ $found)
            }
        }
    }

    $files | uniq
}

export def view-logs [level: string, --fzf(-f)] {
    let valid_levels = ["slog" "info" "warn" "fail" "success" "output" "error" "all"]
    if not ($level in $valid_levels) {
        fail "Usage: view-logs <slog|info|warn|fail|success|output|error|all> [--fzf]"
        return
    }

    let log_dir = $env.DOTFILES_VIEW_LOG_DIR
    if not ($log_dir | path exists) {
        fail $"No logs found at ($log_dir)"
        return
    }

    let files = (collect-files $log_dir (levels-for $level))
    if ($files | is-empty) {
        warn $"No matching log entries for level '($level)'"
        return
    }

    mut merged = []
    for file in $files {
        try {
            $merged = ($merged ++ (open $file | lines))
        }
    }

    let output = ($merged | where { |line| $line | is-not-empty } | sort | each { |line| colorize $line })

    if $fzf {
        if not (has-cmd fzf) {
            fail "fzf not installed"
            return
        }

        $output | str join "\n" | fzf --ansi --no-sort --height=100% --prompt="logs> "
    } else {
        print ($output | str join "\n")
    }
}

export def main [level: string, --fzf(-f)] {
    if $fzf {
        view-logs $level --fzf
    } else {
        view-logs $level
    }
}