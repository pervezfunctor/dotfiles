#! /usr/bin/env nu

use utils.nu *
use exports.nu *

export-env {
    $env.DOT_DIR = ($env.DOT_DIR? | default ($env.HOME | path join ".ilm"))
}

export def --env init-shellrc [--interactive] {
    environs
    init-exports
    eval-brew | ignore

    let pyenv_root = ($env.HOME | path join ".pyenv")
    if ($pyenv_root | path exists) {
        $env.PYENV_ROOT = $pyenv_root
        spath-export ($pyenv_root | path join "bin")
    }

    let conda_bin = ($env.HOME | path join "miniconda3" "bin")
    if ($conda_bin | path exists) {
        spath-export $conda_bin
    }

    let pnpm_home = ($env.HOME | path join ".local" "share" "pnpm")
    if ($pnpm_home | path exists) {
        $env.PNPM_HOME = $pnpm_home
        spath-export $pnpm_home
    }

    if $interactive {
        if (has-cmd carapace) {
            $env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
        }
    }
}

export def main [--interactive] {
    if $interactive {
        init-shellrc --interactive
    } else {
        init-shellrc
    }
}