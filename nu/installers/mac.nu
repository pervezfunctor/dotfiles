#! /usr/bin/env nu

# macOS-specific installer functions

use ../share/utils.nu *
use common.nu *

# Amethyst configuration
export def amethyst-confstall []: nothing -> nothing {
    slog "amethyst config"
    stowdf amethyst
    slog "amethyst config done!"
}

# Aerospace configuration
export def aerospace-confstall []: nothing -> nothing {
    slog "aerospace config"
    stowgf aerospace
}

# macOS configuration
export def macos-confstall []: nothing -> nothing {
    stow -d $env.DOT_DIR -t $env.HOME --dotfiles -R aerospace
    stow -d $env.DOT_DIR -t $env.HOME --dotfiles -R amethyst
}

# VSCode binary installation
export def vscode-binstall []: nothing -> nothing {
    bi visual-studio-code
}

# Terminal binary installation
export def terminal-binstall []: nothing -> nothing {
    bic ghostty wezterm
}

# UI installation
export def ui-install []: nothing -> nothing {
    bic nikitabobko/tap/aerospace
}

# UV installation
export def uv-install []: nothing -> nothing {
    bis uv
}

# Apps slim installation
export def apps-slim-install []: nothing -> nothing {
    bic zoom telegram-desktop
}

# Apps installation
export def apps-install []: nothing -> nothing {
    apps-slim-install

    bi deluge
    bic google-chrome microsoft-remote-desktop bitwarden obsidian
}

# Core installation
export def core-install []: nothing -> nothing {
    softwareupdate --install-rosetta --agree-to-license
    brew-install
    bi mas coreutils bash curl wget trash tree unzip coreutils stow \
        nmap gawk
}

# Essential installation
export def essential-install []: nothing -> nothing {
    slog "Installing Essential packages"

    bis p7zip unar zip pkgx zstd newt

    slog "Essential packages installation done!"
}

# CLI slim installation
export def cli-slim-install []: nothing -> nothing {
    bis starship ripgrep gh bat jq fzf zoxide eza \
        reattach-to-user-namespace zsh-syntax-highlighting zsh-autosuggestions
}

# CLI installation
export def cli-install []: nothing -> nothing {
    bis tmux pkg-config urlview htop starship shellcheck shfmt ripgrep neovim \
        luarocks tealdeer lsd fd git-delta just gum
}

# JetBrains Mono installation
export def jetbrains-mono-install []: nothing -> nothing {
    bic font-jetbrains-mono-nerd-font
}

# Nerd fonts installation
export def nerd-fonts-install []: nothing -> nothing {
    jetbrains-mono-install
    bic font-monaspace-nerd-font
    bic font-caskaydia-mono-nerd-font
}

# Fonts installation
export def fonts-install []: nothing -> nothing {
    nerd-fonts-install
}

# C++ installation
export def cpp-install []: nothing -> nothing {
    slog "Installing C++"

    bi cmake boost catch2 ccache cppcheck pre-commit

    slog "C++ installation done!"
}

# Podman installation
export def podman-install []: nothing -> nothing {
    slog "Installing Container tools"

    bi podman
    bic podman-desktop
    podman machine init
    podman machine start
    if not ("/Applications/Docker.app" | path exists) {
        bic docker
    }

    slog "Container tools installation done!"
}

# VM installation
export def vm-install []: nothing -> nothing {
    slog "Installing virtualization packages"

    bi orbstack colima jq

    slog "Virtualization packages installation done!"
}

# Pyenv Mac installation
export def pyenv-mac-install []: nothing -> nothing {
    slog "Installing pyenv"
    bi pyenv pyenv-virtualenv
}

# Emacs binary installation
export def emacs-binstall []: nothing -> nothing {
    if ("/Applications/Emacs.app" | path exists) {
        return
    }
    if ("/usr/local/opt/emacs-mac" | path exists) {
        return
    }

    slog "Installing emacs"

    bic emacs-mac

    slog "emacs installation done!"
}

# Docker installation
export def docker-install []: nothing -> nothing {
    if (has-cmd docker) {
        return
    }
    if ("/Applications/Docker.app" | path exists) {
        return
    }

    slog "Installing docker"

    let docker_dmg = ~/Downloads/Docker.dmg | path expand
    if not ($docker_dmg | path exists) {
        curl -sSL https://desktop.docker.com/mac/main/amd64/Docker.dmg -o $docker_dmg
    } else {
        warn "Docker.dmg already exists, skipping download"
    }

    bis dive

    if ("/Volumes/Docker" | path exists) {
        warn "Docker.dmg already mounted, unmounting"
        sudo hdiutil detach /Volumes/Docker
    }
    sudo hdiutil attach $docker_dmg
    sudo /Volumes/Docker/Docker.app/Contents/MacOS/install
    sudo hdiutil detach /Volumes/Docker

    slog "docker installation done!"
}

# Nix Darwin mainstall
export def nix-darwin-mainstall []: nothing -> nothing {
    min-mainstall
    nix-install

    let cfg_dir = ~/nix-config | path expand
    let hm_dir = $env.DOT_DIR | path join "extras" "home-manager"

    if not (dir-exists $hm_dir) {
        die "home-manager config folder does not exist, cannot install home-manager."
    }

    slog $"Copying home-manager config to ($cfg_dir)..."
    if not (cp -r $hm_dir $cfg_dir) {
        die "Failed to copy home-manager config"
    }

    slog "Rebuilding system with flake..."
    if not (sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake $"($cfg_dir)#mac") {
        die "nix-darwin-rebuild failed"
    }

    vscode-groupstall
    docker-install

    cmd-check nix darwin-rebuild

    slog "nix-darwin installation done!"
    slog $"Your configuration is at ($cfg_dir)"
    slog "Update your configuration, and run:"
    slog $"darwin-rebuild switch --flake ($cfg_dir)#mac"
    slog "Commit and push your configuration to keep it safe."
}

# Nix Darwin dev mainstall
export def nix-darwin-dev-mainstall []: nothing -> nothing {
    nix-darwin-mainstall
}

# macOS settings installation
export def macos-settings-install []: nothing -> nothing {
    defaults write -g NSWindowShouldDragOnGesture -bool true
    defaults write com.apple.finder AppleShowAllFiles -bool true

    # Disable the sound effects on boot
    sudo nvram SystemAudioVolume=" "

    # Disable automatic capitalization
    defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

    # Disable smart dashes
    defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

    # Disable automatic period substitution
    defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

    # Disable smart quotes
    defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

    # Disable auto-correct
    defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

    # Trackpad: enable tap to click
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

    # Trackpad: map bottom right corner to right-click
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
    defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
    defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

    # Disable "natural" scrolling
    defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

    # Enable full keyboard access
    defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

    # Use scroll gesture with Ctrl to zoom
    defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
    defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144
    defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true

    # Disable press-and-hold for keys
    defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

    # Set fast keyboard repeat rate
    defaults write NSGlobalDomain KeyRepeat -int 1
    defaults write NSGlobalDomain InitialKeyRepeat -int 10

    # Finder: show hidden files
    defaults write com.apple.finder AppleShowAllFiles -bool true

    # Finder: show all filename extensions
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true

    # Keep folders on top when sorting
    defaults write com.apple.finder _FXSortFoldersFirst -bool true

    # Search current folder by default
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

    # Disable warning when changing file extension
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

    # Avoid creating .DS_Store files
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

    # Use list view in Finder
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

    # Privacy: don't send search queries to Apple
    defaults write com.apple.Safari UniversalSearchEnabled -bool false
    defaults write com.apple.Safari SuppressSearchSuggestions -bool true

    # Use AirDrop over every interface
    defaults write com.apple.NetworkBrowser BrowseAllInterfaces 1

    # Show the ~/Library folder
    chflags nohidden ~/Library

    # Set Finder prefs for showing volumes
    defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
    defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

    # Hide Safari's bookmark bar
    defaults write com.apple.Safari.plist ShowFavoritesBar -bool false

    # Show Safari's URL display
    defaults write com.apple.Safari ShowOverlayStatusBar -bool true

    # Set up Safari for development
    defaults write com.apple.Safari.SandboxBroker ShowDevelopMenu -bool true
    defaults write com.apple.Safari.plist IncludeDevelopMenu -bool true
    defaults write com.apple.Safari.plist WebKitDeveloperExtrasEnabledPreferenceKey -bool true
    defaults write com.apple.Safari.plist "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" -bool true
    defaults write NSGlobalDomain WebKitDeveloperExtras -bool true
}
