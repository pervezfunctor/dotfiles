#! /usr/bin/env nu

use utils.nu *

def command-candidates [] {
    let nu_commands = (scope commands | get name)
    let external = if (has-cmd bash) {
        let result = (do -i { ^bash -lc 'compgen -c | sort -u' } | complete)
        if $result.exit_code == 0 {
            $result.stdout | lines
        } else {
            []
        }
    } else {
        []
    }

    [$nu_commands $external] | flatten | uniq | sort
}

export def find-exec [query?: string, --fzf(-f)] {
    let commands = (command-candidates)

    if $fzf {
        if not (has-cmd fzf) {
            fail "fzf not installed"
            return ""
        }

        $commands | str join "\n" | fzf --height 40% --reverse
    } else if ($query | is-not-empty) {
        $commands | where { |cmd| $cmd | str contains $query }
    } else {
        $commands
    }
}

export def main [query?: string, --fzf(-f)] {
    if $fzf {
        find-exec $query --fzf
    } else {
        find-exec $query
    }
}