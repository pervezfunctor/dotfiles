#! /usr/bin/env nu

use utils.nu *

def default-arch [] {
    let result = (do -i { ^uname -m } | complete)
    if $result.exit_code == 0 {
        $result.stdout | str trim
    } else {
        "x86_64"
    }
}

def default-os [] {
    match ($nu.os-info.name | default "linux") {
        "macos" => "Darwin"
        _ => "Linux"
    }
}

export def get-latest-github-release-tag [url: string] {
    let cleaned = ($url | str trim | str replace --regex '/+$' '')
    let parts = ($cleaned | split row "/")

    if ($parts | length) < 2 {
        die $"Invalid GitHub URL: ($url)"
    }

    let repo = ($parts | last)
    let owner = ($parts | reverse | get 1)
    let api_url = $"https://api.github.com/repos/($owner)/($repo)/releases/latest"

    let release = (try { http get $api_url } catch { null })
    let tag = ($release.tag_name? | default "")

    if ($tag | is-empty) {
        die $"Could not fetch latest release tag for ($url)"
    }

    $tag
}

export def gum-latest-install [arch?: string, os?: string] {
    check-cmds tar

    let target_arch = ($arch | default (default-arch))
    let target_os = ($os | default (default-os))
    let tag = (get-latest-github-release-tag "https://github.com/charmbracelet/gum")
    let version = ($tag | str replace --regex '^v' '')
    let tarball = $"gum_($version)_($target_os)_($target_arch).tar.gz"
    let url = $"https://github.com/charmbracelet/gum/releases/download/($tag)/($tarball)"

    let tmp_result = (do -i { ^mktemp -d } | complete)
    let tmpdir = if $tmp_result.exit_code == 0 {
        $tmp_result.stdout | str trim
    } else {
        "/tmp/gum-install"
    }

    mkdir $tmpdir

    let archive = ($tmpdir | path join $tarball)
    if not (download-to $url $archive) {
        rm -rf $tmpdir
        die $"Failed to download Gum from ($url)"
    }

    let extract_result = (do -i { ^tar -xzf $archive -C $tmpdir } | complete)
    if $extract_result.exit_code != 0 {
        rm -rf $tmpdir
        die "Failed to extract Gum archive"
    }

    let binary = ($tmpdir | path join "gum")
    if not ($binary | path exists) {
        rm -rf $tmpdir
        die "Extracted archive did not contain gum binary"
    }

    let bin_dir = ($env.HOME | path join ".local" "bin")
    mkdir $bin_dir
    mv -f $binary ($bin_dir | path join "gum")
    rm -rf $tmpdir

    success $"Gum ($tag) installed to ($bin_dir | path join 'gum')"
}

export def main [arch?: string, os?: string] {
    gum-latest-install $arch $os
}