#! /usr/bin/env nu

use logs.nu *

export-env {
    $env.ILMG_LOG_DIR = ($env.ILMG_LOG_DIR? | default ($env.LOG_DIR? | default ($env.ILM_LOG_DIR? | default (($env.XDG_STATE_HOME? | default ($env.HOME | path join ".local" "state")) | path join "dotfiles" "logs"))))
}

def rotate-one [file: string, keep: int] {
    if not ($file | path exists) {
        return
    }

    for i in ((1..$keep) | reverse) {
        let old_file = $"($file).($i)"
        let next_file = $"($file).(($i + 1))"
        if ($old_file | path exists) {
            mv -f $old_file $next_file
        }
    }

    mv -f $file $"($file).1"
    "" | save -f $file
}

export def --env dotfiles-log-init [] {
    log-init --dir $env.ILMG_LOG_DIR
}

export def dotfiles-log-close [] {
    null
}

export def dotfiles-log-rotate [keep: int = 7] {
    mkdir $env.ILMG_LOG_DIR
    let files = (ls $env.ILMG_LOG_DIR | where type == file | get name)
    for file in $files {
        rotate-one $file $keep
    }
}