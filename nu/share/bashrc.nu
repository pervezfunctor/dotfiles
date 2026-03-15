#! /usr/bin/env nu

use utils.nu *
use shellrc.nu *

export-env {
    $env.XDG_CONFIG_HOME = ($env.XDG_CONFIG_HOME? | default ($env.HOME | path join ".config"))
    $env.DOT_DIR = ($env.DOT_DIR? | default ($env.HOME | path join ".ilm"))
}

export def --env init-bashrc [] {
    if not (dir-exists $env.DOT_DIR) {
        return
    }

    init-shellrc --interactive

    if (has-cmd carapace) {
        $env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
    }
}

export def local-override-files [] {
    [
        ($env.HOME | path join ".localbashrc")
        ($env.XDG_CONFIG_HOME | path join "localbashrc")
    ]
}

export def main [] {
    init-bashrc
}