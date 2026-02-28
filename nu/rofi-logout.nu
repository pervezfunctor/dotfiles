#! /usr/bin/env nu

# Power menu using rofi

use ./share/utils.nu *

export def main [] {
    if not (has-cmd rofi) {
        die "rofi is not installed"
    }

    let choice = try {
        ["Lock", "Logout", "Reboot", "Shutdown"] | str join "\n" | rofi -dmenu -i -p "Power Menu" | str trim
    } catch {
        ""
    }

    match $choice {
        "Lock" => { swaylock }
        "Logout" => { swaymsg exit }
        "Reboot" => { systemctl reboot }
        "Shutdown" => { systemctl poweroff }
        _ => { exit 0 }
    }
}

