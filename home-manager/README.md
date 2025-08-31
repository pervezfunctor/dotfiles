# Home Manager Configuration

This directory contains a [Nix Home Manager](https://github.com/nix-community/home-manager) configuration for managing user environment and dotfiles declaratively.

## Overview

Home Manager allows you to manage your user environment using Nix, providing reproducible and declarative configuration for your shell, packages, and dotfiles. This configuration is part of the ILM (Integrated Linux Management) system.

## Directory Structure

```
home-manager/
├── README.md                    # This file
    ├── flake.nix           # Main flake configuration
    ├── flake.lock          # Locked dependency versions
    ├── home.nix            # Home Manager configuration
    ├── vars.nix            # Environment variables
    └── hms                 # Helper script for switching
```

## Configuration Files

### `vars.nix`
Environment variable definitions that dynamically fetch:
- `username`: Current user from `$USER` environment variable
- `homeDirectory`: Home directory from `$HOME` environment variable

You can replace the above variables to static values if needed.

### `hms`
A convenience script for applying Home Manager configurations with backup support.

## Installed Packages

The configuration includes a comprehensive set of development and system tools:

### Development Tools
- **devbox**: Portable development environments
- **devenv**: Development environment management
- **gh**: GitHub CLI
- **lazygit**: Terminal UI for Git

### System Utilities
- **bat**: Enhanced cat with syntax highlighting
- **carapace**: Multi-shell completion generator
- **delta**: Syntax-highlighting pager for git
- **eza**: Modern replacement for ls
- **fzf**: Fuzzy finder
- **jq**: JSON processor
- **just**: Command runner
- **ripgrep**: Fast text search
- **stow**: Symlink farm manager
- **tealdeer**: Fast tldr client
- **trash-cli**: Command line trash
- **yazi**: Terminal file manager
- **zoxide**: Smart directory jumper

## Shell Configuration

### Zsh Setup
- **Completion**: Enabled with auto-suggestions
- **Syntax Highlighting**: Enabled for better readability
- **Starship Prompt**: Modern, fast prompt with Git integration
- **Custom Aliases**: Including `hms` for Home Manager switching/updating

### Environment Integration
The configuration automatically integrates with the ILM dotfiles by:
- Adding ILM directories to PATH (`~/.ilm/bin`, `~/.ilm/bin/vt`)
- Adding Volta and local bin directories to PATH
- Sourcing ILM utility scripts (`utils`, `fns`, `aliases`)

### Direnv Integration
- **direnv**: Automatically loads environment variables from `.envrc` files
- **nix-direnv**: Enhanced Nix support for direnv

## Usage

### Initial Setup
1. Ensure Nix is installed with flakes enabled

```bash
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm
    source_if_exists /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

2. Navigate to the home-manager configuration directory:
   ```bash
   cd ~/.ilm/home-manager/dot-config/home-manager
   ```

### Applying Configuration

Using the helper script

```bash
./hms
```

Change your default shell to zsh if you haven't already.

```bash
chsh -s $(which zsh)
```

Now you could use the alias, `hms` to apply the configuration.

```bash
hms
```

Or use the following command.

```bash
nix run home-manager -- switch --flake .#"${USER}" --impure -b bak
```

### Making Changes

1. Edit the configuration files (`home.nix`, `flake.nix`, etc.)
2. Apply changes using one of the methods above
3. Home Manager will create backups of existing configurations

### Adding Packages

To add new packages, edit `home.nix` and add them to the `home.packages` list:
```nix
home.packages = with pkgs; [
  # existing packages...
  new-package-name
];
```

### Updating Dependencies

Update the flake lock file to get the latest versions:
```bash
nix flake update
```
