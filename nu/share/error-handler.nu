#! /usr/bin/env nu

use std/log

export def error-context [message: string, --exit-code(-e): int = 1, --command(-c): string = "", --script(-s): string = "", --line(-l): int = 0, --function(-f): string = "main", --stack(-k): list<string> = []] {
    {
        message: $message
        exit_code: $exit_code
        command: $command
        script: $script
        line: $line
        function: $function
        time: (date now)
        stack: $stack
    }
}

export def print-error-context [message: string, --exit-code(-e): int = 1, --command(-c): string = "", --script(-s): string = "", --line(-l): int = 0, --function(-f): string = "main", --stack(-k): list<string> = []] {
    let ctx = (error-context $message --exit-code $exit_code --command $command --script $script --line $line --function $function --stack $stack)

    log error "========================= ERROR ========================="
    log error $"Script: ($ctx.script)"
    log error $"Line: ($ctx.line)"
    log error $"Function: ($ctx.function)"
    log error $"Command: ($ctx.command)"
    log error $"Exit Code: ($ctx.exit_code)"
    log error $"Time: ($ctx.time)"

    if ($ctx.stack | is-not-empty) {
        log error "Call stack:"
        for frame in $ctx.stack {
            log error $"  ($frame)"
        }
    }

    $ctx
}

export def fail-with-context [message: string, --exit-code(-e): int = 1, --command(-c): string = "", --script(-s): string = "", --line(-l): int = 0, --function(-f): string = "main", --stack(-k): list<string> = []] {
    print-error-context $message --exit-code $exit_code --command $command --script $script --line $line --function $function --stack $stack | ignore
    exit $exit_code
}