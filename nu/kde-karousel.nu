#! /usr/bin/env nu

# Install Karousel KWin script for KDE

use ./share/utils.nu *

const REPO = "peterfajdiga/karousel"
const DEST = "~/.local/share/kwin/scripts/karousel"

# Download latest release from GitHub
export def latest-from-github [repo: string, outfile: string]: nothing -> string {
    let api = $"https://api.github.com/repos/($repo)/releases/latest"

    # Get download URL
    let response = try {
        curl -sL $api | complete
    } catch {
        die $"Failed to fetch release info for ($repo)"
    }

    let url = $response.stdout | from json | get tarball_url? | default ""

    if ($url | is-empty) {
        die $"Unable to find latest release URL for ($repo)"
    }

    info $"Downloading: ($url)"
    curl -L -o $outfile $url

    $outfile
}

export def main [] {
    let dest_path = $DEST | path expand

    if ($dest_path | path exists) {
        die $"Destination already exists: ($dest_path)"
        info "Refusing to overwrite. Delete it if you want a fresh install."
        exit 1
    }

    mkdir ($dest_path | path dirname)

    let tmp_dir = mktemp -d
    cd $tmp_dir

    let archive = latest-from-github $REPO "karousel-latest.tar.gz"

    # Extract
    mkdir extracted
    tar -xzf $archive -C extracted

    # Find top directory
    let top_dir = ls extracted | where type == dir | get 0?.name? | default ""

    if ($top_dir | is-empty) {
        die "Extraction failed (no top directory found)"
    }

    mv $top_dir $dest_path

    cd ~
    rm -rf $tmp_dir

    success $"Installed karousel into: ($dest_path)"
    info "This script will now refuse further runs until you remove that directory."
}

