#! /usr/bin/env nu

use std/log

export-env {
    $env.LOG_LEVEL = ($env.LOG_LEVEL? | default "INFO")
    $env.LOG_DIR = ($env.LOG_DIR? | default ($env.ILM_LOG_DIR? | default (($env.DOT_DIR? | default $env.HOME) | path join "logs")))
    $env.LOG_DISABLE_REDIRECT = ($env.LOG_DISABLE_REDIRECT? | default 0)
}

def now-stamp [] {
    date now | format date '%Y-%m-%dT%H:%M:%S.%3f%z'
}

def normalise-level [level: string] {
    match ($level | str upcase) {
        "TRACE" => "TRACE"
        "DEBUG" => "DEBUG"
        "INFO" => "INFO"
        "WARN" => "WARN"
        "FAIL" => "FAIL"
        "ERROR" => "FAIL"
        "SUCCESS" => "SUCCESS"
        _ => "INFO"
    }
}

def level-value [level: string] {
    match (normalise-level $level) {
        "TRACE" => 10
        "DEBUG" => 20
        "INFO" => 30
        "SUCCESS" => 35
        "WARN" => 40
        "FAIL" => 50
        _ => 30
    }
}

def file-for-level [level: string] {
    match (normalise-level $level) {
        "WARN" => ($env.LOG_WARN_FILE? | default ($env.LOG_DIR | path join $"($env.LOG_SESSION).warn.log"))
        "FAIL" => ($env.LOG_FAIL_FILE? | default ($env.LOG_DIR | path join $"($env.LOG_SESSION).fail.log"))
        "SUCCESS" => ($env.LOG_SUCCESS_FILE? | default ($env.LOG_DIR | path join $"($env.LOG_SESSION).success.log"))
        _ => ($env.LOG_INFO_FILE? | default ($env.LOG_DIR | path join $"($env.LOG_SESSION).info.log"))
    }
}

export def --env log-init [--dir(-d): string, --session(-s): string, --force] {
    if (($env.LOGGING_INITIALIZED? | default false) and (not $force)) {
        return
    }

    let target_dir = ($dir | default $env.LOG_DIR)
    let session = ($session | default (date now | format date '%Y%m%d-%H%M%S'))

    mkdir $target_dir

    $env.LOG_DIR = $target_dir
    $env.LOG_SESSION = $session
    $env.LOG_INFO_FILE = ($target_dir | path join $"($session).info.log")
    $env.LOG_WARN_FILE = ($target_dir | path join $"($session).warn.log")
    $env.LOG_FAIL_FILE = ($target_dir | path join $"($session).fail.log")
    $env.LOG_SUCCESS_FILE = ($target_dir | path join $"($session).success.log")
    $env.LOG_STDOUT_FILE = ($target_dir | path join $"($session).stdout.log")
    $env.LOG_STDERR_FILE = ($target_dir | path join $"($session).stderr.log")

    for file in [
        $env.LOG_INFO_FILE
        $env.LOG_WARN_FILE
        $env.LOG_FAIL_FILE
        $env.LOG_SUCCESS_FILE
        $env.LOG_STDOUT_FILE
        $env.LOG_STDERR_FILE
    ] {
        if not ($file | path exists) {
            "" | save -f $file
        }
    }

    $env.LOGGING_INITIALIZED = true
}

export def --env log-set-level [level: string] {
    $env.LOG_LEVEL = (normalise-level $level)
}

export def log-redirect-stdstreams [] {
    log warning "Stream redirection is not implemented in nushell compatibility mode"
}

def write-log [level: string, message: string, quiet: bool = false] {
    if not ($env.LOGGING_INITIALIZED? | default false) {
        log-init
    }

    let label = (normalise-level $level)
    let threshold = (level-value ($env.LOG_LEVEL? | default "INFO"))
    let current = (level-value $label)
    if $current < $threshold {
        return
    }

    let line = $"[($now-stamp)] [($label)] ($message)"
    $line | save --append (file-for-level $label)

    if not $quiet {
        match $label {
            "WARN" => (log warning $message)
            "FAIL" => (log error $message)
            "SUCCESS" => (log info $"[OK] ($message)")
            _ => (log info $message)
        }
    }
}

export def log-trace [message: string, --quiet] { write-log "TRACE" $message $quiet }
export def log-debug [message: string, --quiet] { write-log "DEBUG" $message $quiet }
export def log-info [message: string, --quiet] { write-log "INFO" $message $quiet }
export def log-warn [message: string, --quiet] { write-log "WARN" $message $quiet }
export def log-fail [message: string, --quiet] { write-log "FAIL" $message $quiet }
export def log-success [message: string, --quiet] { write-log "SUCCESS" $message $quiet }
export def slog [message: string, --quiet] { write-log "INFO" $message $quiet }
export def info [message: string, --quiet] { write-log "INFO" $message $quiet }
export def warn [message: string, --quiet] { write-log "WARN" $message $quiet }
export def fail [message: string, --quiet] { write-log "FAIL" $message $quiet }
export def success [message: string, --quiet] { write-log "SUCCESS" $message $quiet }