#! /usr/bin/env nu

use utils.nu

const HOMEBREW_DIR = "/var/home/linuxbrew"
const BREW_PREFIX = "/var/home/linuxbrew/.linuxbrew"
const PROFILE_FILE = "/etc/profile.d/homebrew.sh"

# ============================================
# Homebrew Installation Functions
# ============================================

export def homebrew-get-user []: nothing -> string {
    let user_name = ($env.SUDO_USER? | default (do { ^logname } | complete | get stdout? | default $env.USER | str trim))

    let id_result = (do { id -u $user_name } | complete)
    if $id_result.exit_code != 0 {
        die $"User '($user_name)' does not exist"
    }

    $user_name
}

export def homebrew-setup-dir [user_name: string]: nothing -> nothing {
    slog $"Setting up Homebrew directory: ($HOMEBREW_DIR)"

    if not ($HOMEBREW_DIR | path exists) {
        let mkdir_result = (do { sudo mkdir -p $HOMEBREW_DIR } | complete)
        if $mkdir_result.exit_code != 0 {
            die "Failed to create Homebrew directory"
        }
        slog "Created Homebrew directory"
    } else {
        slog "Homebrew directory already exists"
    }

    let chown_result = (do { sudo chown -R $"($user_name):($user_name)" $HOMEBREW_DIR } | complete)
    if $chown_result.exit_code != 0 {
        die "Failed to set directory ownership"
    }

    success "Homebrew directory ready"
}

export def homebrew-install [user_name: string]: nothing -> nothing {
    slog $"Installing Homebrew for user: ($user_name)"

    let brew_exe = $"($BREW_PREFIX)/bin/brew"
    if ($brew_exe | path exists) {
        slog "Homebrew already installed"
    } else {
        slog "Cloning Homebrew repository"

        let clone_cmd = $"git clone --depth=1 https://github.com/Homebrew/brew ($BREW_PREFIX)"
        let clone_result = (do { sudo -u $user_name bash -c $clone_cmd } | complete)
        if $clone_result.exit_code != 0 {
            die "Failed to clone Homebrew"
        }
    }

    slog "Updating Homebrew"

    let update_cmd = $"eval \"\$\(($brew_exe) shellenv\)\" && brew update --quiet"
    let update_result = (do { sudo -u $user_name bash -c $update_cmd } | complete)
    if $update_result.exit_code != 0 {
        die "Failed to update Homebrew"
    }

    success "Homebrew installation complete"
}

export def homebrew-setup-profile []: nothing -> nothing {
    slog $"Configuring profile snippet: ($PROFILE_FILE)"

    let snippet = $"eval \"\$\(($BREW_PREFIX)/bin/brew shellenv\)\""

    let profile_exists = (do { sudo test -f $PROFILE_FILE } | complete | get exit_code) == 0
    if $profile_exists {
        let grep_result = (do { sudo grep -Fq $snippet $PROFILE_FILE } | complete)
        if $grep_result.exit_code == 0 {
            slog "Profile snippet already exists"
            return
        }
        slog "Updating existing snippet"
    }

    let tee_result = (do { echo $snippet | sudo tee $PROFILE_FILE } | complete)
    if $tee_result.exit_code != 0 {
        die "Failed to write profile snippet"
    }

    let chmod_result = (do { sudo chmod 644 $PROFILE_FILE } | complete)
    if $chmod_result.exit_code != 0 {
        warn "Failed to set profile file permissions"
    }

    success "Profile snippet installed"
}

export def homebrew-verify [user_name: string]: nothing -> nothing {
    slog "Verifying Homebrew installation"

    let verify_cmd = $"source ($PROFILE_FILE) && brew --version >/dev/null"
    let verify_result = (do { sudo -u $user_name bash -c $verify_cmd } | complete)
    if $verify_result.exit_code != 0 {
        die "Homebrew verification failed"
    }

    success "Homebrew verification successful"
}

export def homebrew-setup-atomic []: nothing -> nothing {
    if not (is-std-atomic) {
        die "Not an atomic system. Exiting."
    }

    slog "Starting Homebrew installation"

    has-cmd git

    let user_name = (homebrew-get-user)

    homebrew-setup-dir $user_name
    homebrew-install $user_name
    homebrew-setup-profile
    homebrew-verify $user_name

    success $"Homebrew installed at ($BREW_PREFIX)"
    slog "Logout/login or source your shell to activate brew."
}
