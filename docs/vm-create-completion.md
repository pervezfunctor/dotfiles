# VM-Create Completion Scripts

This document provides instructions for installing and using the bash and zsh completion scripts for the `vm-create` command.

## Bash Completion

### Installation

1. Copy the completion script to your bash completion directory:
   ```bash
   # For system-wide installation
   sudo cp bash/completions/vm-create.bash /etc/bash_completion.d/

   # Or for user-specific installation
   mkdir -p ~/.local/share/bash-completion/completions
   cp bash/completions/vm-create.bash ~/.local/share/bash-completion/completions/
   ```

2. Reload bash completion:
   ```bash
   source ~/.bashrc
   # or restart your terminal
   ```

### Usage

Once installed, you can use tab completion with the `vm-create` command:

```bash
# Complete distributions
vm-create --distro <TAB>
# ubuntu  fedora  arch  debian  alpine  tumbleweed  opensuse  tw

# Complete options
vm-create <TAB>
# --distro      --name        --memory      --vcpus       --disk-size
# --ssh-key     --bridge      --username    --password    --docker
# --brew        --nix         --dotfiles    --help        -h

# Complete memory sizes
vm-create --memory <TAB>
# 1024  2048  4096  8192  12288  16384

# Complete disk sizes
vm-create --disk-size <TAB>
# 20G  40G  60G  80G  100G  120G
```

## Zsh Completion

### Installation

1. Copy the completion script to your zsh completion directory:
   ```bash
   # For system-wide installation
   sudo cp zsh/completions/_vm-create /usr/share/zsh/site-functions/

   # Or for user-specific installation
   mkdir -p ~/.zsh/completions
   cp zsh/completions/_vm-create ~/.zsh/completions/
   ```

2. Add the completion directory to your fpath in ~/.zshrc (if using user-specific installation):
   ```bash
   fpath=(~/.zsh/completions $fpath)
   autoload -U compinit && compinit
   ```

3. Reload zsh configuration:
   ```bash
   source ~/.zshrc
   # or restart your terminal
   ```

### Usage

Once installed, you can use tab completion with the `vm-create` command:

```bash
# Complete distributions with descriptions
vm-create <TAB>
# ubuntu      - Ubuntu Linux (default: questing 25.10)
# fedora      - Fedora Linux (default: 42)
# arch        - Arch Linux (default: latest)
# debian      - Debian Linux (default: trixie 13)
# alpine      - Alpine Linux (default: 3.22)
# tumbleweed  - openSUSE Tumbleweed (default: latest)
# opensuse    - openSUSE Tumbleweed (alias for tumbleweed)
# tw          - openSUSE Tumbleweed (short alias)

# Complete options with descriptions
vm-create --<TAB>
# --distro     - Distribution to install
# --name       - VM name
# --memory     - RAM in MB
# --vcpus      - Number of vCPUs
# --disk-size  - Disk size
# --ssh-key    - SSH public key path
# --bridge     - Network bridge
# --username   - VM username
# --password   - Set password for VM user
# --docker     - Install Docker in the VM
# --brew       - Install Homebrew and essential development tools
# --nix        - Install Nix using Determinate Systems installer
# --dotfiles   - Install dotfiles with specified options (must be last)
# --help       - Show this help
# -h           - Show this help
```

## Features

Both completion scripts provide:

- **Distribution completion**: Lists all supported Linux distributions
- **Option completion**: Completes all available command-line options
- **Value completion**: Suggests common values for memory, disk size, vCPUs, etc.
- **File completion**: Completes file paths for SSH keys
- **Dotfiles completion**: Suggests common dotfiles options
- **Smart filtering**: Prevents suggesting --dotfiles if it's already used

## Examples

```bash
# Create Ubuntu VM with tab completion
vm-create --distro ubuntu --name test-vm --memory 4096 --vcpus 2 --disk-size 40G

# Create Fedora VM with Docker
vm-create --distro fedora --docker

# Create Arch VM with dotfiles
vm-create --distro arch --dotfiles shell-slim docker

# Use completion to explore options
vm-create --help
