#! /usr/bin/env nu

use utils.nu *

export def main [port?: int] {
    if ($port | is-empty) {
        ssh-enable
    } else {
        ssh-enable $port
    }
}