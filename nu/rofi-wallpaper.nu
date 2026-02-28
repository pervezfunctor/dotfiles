#! /usr/bin/env nu

# Wallpaper picker using rofi

use ./share/utils.nu *

const THUMB_SIZE = "800x500"
const CACHE_DIR = "~/.cache/wallpaper-thumbs"

# Generate thumbnail for wallpaper
export def generate-thumb [img: string, cache_dir: string]: nothing -> string {
    let base = $img | path basename
    let thumb = $cache_dir | path join $"($base).png"

    if not ($thumb | path exists) {
        try {
            magick $img -auto-orient -thumbnail $"($THUMB_SIZE)^" -gravity center -extent $THUMB_SIZE $thumb
        } catch {
            warn $"Failed to create thumbnail for ($img)"
            return ""
        }
    }

    $thumb
}

export def main [
    wallpaper_dir?: string  # Wallpaper directory (default: ~/Pictures/Wallpapers)
] {
    let wall_dir = $wallpaper_dir | default ($env.HOME | path join "Pictures" "Wallpapers")
    let cache_dir = $CACHE_DIR | path expand

    # Check dependencies
    if not (has-cmd rofi) {
        die "Missing required command: rofi"
    }
    if not (has-cmd swaybg) {
        die "Missing required command: swaybg"
    }
    if not (has-cmd magick) {
        die "Missing required command: magick (ImageMagick)"
    }

    if not ($wall_dir | path exists) {
        die $"Wallpaper directory not found: ($wall_dir)"
    }

    mkdir $cache_dir

    # Collect wallpapers
    let images = glob $"($wall_dir)/*.{jpg,jpeg,png,webp}"

    if ($images | length) == 0 {
        die $"No wallpapers found in ($wall_dir)"
    }

    # Generate entries for rofi
    mut entries = []
    mut thumb_to_img = {}

    for img in $images {
        let thumb = generate-thumb $img $cache_dir
        if not ($thumb | is-empty) {
            $entries = ($entries | append $" \u{0}icon\u{1f}($thumb)")
            $thumb_to_img = ($thumb_to_img | insert $thumb $img)
        }
    }

    if ($entries | length) == 0 {
        die "No valid wallpapers available after filtering"
    }

    # Show rofi
    let selection = try {
        $entries | str join "\n" | rofi -dmenu -p "Wallpaper" -show-icons -i -markup-rows | str trim
    } catch { "" }

    # User cancelled
    if ($selection | is-empty) {
        exit 0
    }

    # Parse selection
    let selected_thumb = $selection | parse -r '.*\x1f(.*)$' | get capture0? | default "" | first

    if ($selected_thumb | is-empty) {
        die "Failed to resolve selected thumbnail"
    }

    let wallpaper = try { $thumb_to_img | get $selected_thumb } catch { "" }

    if ($wallpaper | is-empty) {
        die "Selected wallpaper not mapped"
    }

    if not ($wallpaper | path exists) {
        die $"Wallpaper file disappeared: ($wallpaper)"
    }

    # Apply wallpaper
    try { pkill swaybg } catch {}

    swaybg -i $wallpaper -m fill

    exit 0
}

