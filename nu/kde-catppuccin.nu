#! /usr/bin/env nu

# Install Catppuccin theme for KDE

use ./share/utils.nu *

const REPO_URL = "https://github.com/catppuccin/kde"

export def main [] {
    check-cmds git bash

    let repo_dir = mktemp -d -t "catppuccin-kde-XXXXXX"

    slog "Cloning repository into: $repo_dir"
    let clone_result = try {
        git clone --depth=1 $REPO_URL $repo_dir | complete
    } catch { { exit_code: 1 } }

    if $clone_result.exit_code != 0 {
        die "Clone failed"
    }

    cd $repo_dir

    let install_script = $repo_dir | path join "install.sh"

    if not ($install_script | path exists) {
        die "install.sh not found in repo"
    }

    slog "Running installer"
    chmod +x $install_script

    let install_result = try {
        bash $install_script | complete
    } catch { { exit_code: 1 } }

    if $install_result.exit_code != 0 {
        die "Installer failed"
    }

    slog "Cleaning up"
    frm $repo_dir

    success "Catppuccin KDE theme installation done!"
}

