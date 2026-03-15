#! /usr/bin/env nu

# Atomic-specific installer functions

use ../share/utils.nu *

export def nix-portable-install []: nothing -> nothing {
    smd ~/.local/bin | ignore

    let dest = ("~/.local/bin/nix-portable" | path expand)
    let url = $"https://github.com/DavHau/nix-portable/releases/latest/download/nix-portable-((uname).machine)"

    if (has-cmd curl) {
        curl -fsSL $url -o $dest
    } else if (has-cmd wget) {
        wget -qO $dest $url
    } else {
        warn "curl or wget not installed, skipping nix-portable installation"
        return
    }

    chmod +x $dest
    cmd-check nix-portable
}

export def webi-install []: nothing -> nothing {
    let webi_bin = ("~/.local/bin/webi" | path expand)
    if ($webi_bin | path exists) {
        return
    }

    if (has-cmd curl) {
        curl -fsSL https://webi.sh/webi | sh
    } else if (has-cmd wget) {
        wget -qO- https://webi.sh/webi | sh
    } else {
        warn "curl or wget not installed, skipping webi installation"
        return
    }

    if ($webi_bin | path exists) {
        ^$webi_bin pathman
    } else if (has-cmd webi) {
        webi pathman
    }

    source-if-exists ($env.XDG_CONFIG_HOME | path join "envman" "PATH.env")
    cmd-check webi
}

export def mise-install []: nothing -> nothing {
    let mise_bin = ("~/.local/bin/mise" | path expand)
    if not ($mise_bin | path exists) {
        slog "Installing mise"

        if (has-cmd curl) {
            with-env { MISE_QUIET: 1 } {
                curl -fsSL https://mise.run | sh
            }
        } else if (has-cmd wget) {
            with-env { MISE_QUIET: 1 } {
                wget -qO- https://mise.run | sh
            }
        } else {
            warn "curl or wget not installed, skipping mise installation"
            return
        }
    }

    if ($mise_bin | path exists) {
        ^$mise_bin use -g usage
        ^$mise_bin settings experimental=true
        ^$mise_bin use -g cargo-binstall
    } else {
        warn "mise installation failed"
        return
    }

    cmd-check mise
}
