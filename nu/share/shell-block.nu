#! /usr/bin/env nu

use utils.nu *

def strip-existing-block [lines: list<string>, start_mark: string, end_mark: string] {
    $lines | reduce -f { inside: false, out: [] } { |line, acc|
        if $line == $start_mark {
            { inside: true, out: $acc.out }
        } else if $line == $end_mark {
            { inside: false, out: $acc.out }
        } else if $acc.inside {
            $acc
        } else {
            { inside: false, out: ($acc.out | append $line) }
        }
    } | get out
}

export def ensure-block-in-file [target_file: string, block_name: string, block_content?: string] {
    let content = ($block_content | default ($in | default "" | into string) | str trim)

    if ($content | is-empty) {
        die "Block content cannot be empty"
    }

    if not ($target_file | path exists) {
        die $"Target file not found: ($target_file)"
    }

    if (($target_file | path type) != "file") {
        die $"Target exists but is not a regular file: ($target_file)"
    }

    let start_mark = $"# >>> ($block_name) STARTS HERE >>>"
    let end_mark = $"# <<< ($block_name) ENDS HERE <<<"
    let existing_lines = (open $target_file | lines)
    let cleaned_lines = (strip-existing-block $existing_lines $start_mark $end_mark)
    let block_lines = (($content | lines | prepend $start_mark) | append $end_mark)

    let output_lines = if ($cleaned_lines | is-empty) {
        $block_lines
    } else {
        [$cleaned_lines "" $block_lines] | flatten
    }

    ($output_lines | str join "\n") + "\n" | save -f $target_file
    success $"Added block '($block_name)' to '($target_file)'"
}

export def main [target_file: string, block_name: string, block_content?: string] {
    ensure-block-in-file $target_file $block_name $block_content
}