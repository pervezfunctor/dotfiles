#!/usr/bin/env nu

def main [dir: path = "nu/"] {
    if not ($dir | path exists) {
        print $"❌ Directory does not exist: ($dir)"
        exit 1
    }

    let nu_files = (glob ($dir | path join "**/*.nu") | sort)

    if ($nu_files | is-empty) {
        print $"⚠️ No .nu files found in: ($dir)"
        exit 0
    }

    mut has_errors = false
    mut total_files = 0
    mut passed_files = 0

    for file in $nu_files {
        $total_files += 1
        print $"Checking: ($file)"

        let result = (nu --ide-check 10 $file | complete)

        if $result.exit_code != 0 or ($result.stderr | str length) > 0 {
            print $"  ❌ Error in ($file):"
            print $"  ($result.stderr)"
            $has_errors = true
        } else {
            print $"  ✓ OK"
            $passed_files += 1
        }
    }

    print $"\n($passed_files)/($total_files) files passed"

    if $has_errors {
        print "❌ Some scripts have errors"
        exit 1
    } else {
        print "✓ All scripts passed syntax check"
    }
}
