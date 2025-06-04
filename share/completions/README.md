# Shell Completions for VM and Container Scripts

This directory contains bash and zsh completion scripts for VM and container management commands:
- `vm` and `vm-create` (libvirt/QEMU VMs)
- `ivm` and `ivm-create` (Incus VMs)
- `ict` and `ict-create` (Incus containers)

## Features

### `vm` Command Completions
- **Commands**: Complete all available vm commands (install, list, status, create, etc.)
- **VM Names**: Dynamically complete VM names from `virsh list --all --name`
- **Special Handling**: `vm create` command uses `vm-create` completion logic
- **Context-Aware**: Different completions based on the command (e.g., commands requiring VM names)

### `vm-create` Command Completions
- **Distributions**: Complete supported distributions (ubuntu, fedora, arch, debian)
- **Options**: Complete all command-line options with appropriate values
- **File Paths**: Complete file paths for SSH keys
- **Predefined Values**: Suggest common values for memory, vCPUs, disk size
- **Dotfiles Groups**: Complete available dotfiles groups

### `ivm` Command Completions
- **Commands**: Complete all available ivm commands (install, list, status, create, etc.)
- **VM Names**: Dynamically complete VM names from `incus list`
- **Distributions**: Complete distributions for create command
- **Snapshots**: Complete snapshot names for restore command
- **Context-Aware**: Different completions based on the command

### `ivm-create` Command Completions
- **Options**: Complete all command-line options (--distro, --name, --vcpus, etc.)
- **Distributions**: Complete available distributions (ubuntu, fedora, arch, debian, centos, alpine)
- **Values**: Context-aware completion for specific option values
- **File Paths**: Complete file paths for SSH keys

### `ict` Command Completions
- **Commands**: Complete all available ict commands (install, list, status, create, etc.)
- **Container Names**: Dynamically complete container names from `incus list`
- **Distributions**: Complete distributions for create command
- **Snapshots**: Complete snapshot names for restore command
- **Context-Aware**: Different completions based on the command

### `ict-create` Command Completions
- **Options**: Complete all command-line options (--distro, --name, --vcpus, --privileged, etc.)
- **Distributions**: Complete available distributions (ubuntu, fedora, arch, debian, centos, alpine)
- **Values**: Context-aware completion for specific option values
- **File Paths**: Complete file paths for SSH keys

## Installation

### Bash Completions

#### System-wide Installation (requires root)
```bash
# Copy completion files to system directory
sudo cp share/completions/vm.bash /etc/bash_completion.d/vm
sudo cp share/completions/vm-create.bash /etc/bash_completion.d/vm-create

# Reload bash completions
source /etc/bash_completion
```

#### User-specific Installation
```bash
# Create user completion directory
mkdir -p ~/.local/share/bash-completion/completions

# Copy completion files
cp share/completions/vm.bash ~/.local/share/bash-completion/completions/vm
cp share/completions/vm-create.bash ~/.local/share/bash-completion/completions/vm-create

# Add to ~/.bashrc if not already present
echo 'source ~/.local/share/bash-completion/completions/vm' >> ~/.bashrc
echo 'source ~/.local/share/bash-completion/completions/vm-create' >> ~/.bashrc

# Reload bash
source ~/.bashrc
```

### Zsh Completions

#### System-wide Installation (requires root)
```bash
# Copy completion files to system directory
sudo cp share/completions/_vm /usr/share/zsh/site-functions/_vm
sudo cp share/completions/_vm-create /usr/share/zsh/site-functions/_vm-create

# Reload zsh completions
autoload -U compinit && compinit
```

#### User-specific Installation
```bash
# Create user completion directory
mkdir -p ~/.local/share/zsh/site-functions

# Copy completion files
cp share/completions/_vm ~/.local/share/zsh/site-functions/_vm
cp share/completions/_vm-create ~/.local/share/zsh/site-functions/_vm-create

# Add to ~/.zshrc if not already present
echo 'fpath=(~/.local/share/zsh/site-functions $fpath)' >> ~/.zshrc
echo 'autoload -U compinit && compinit' >> ~/.zshrc

# Reload zsh
source ~/.zshrc
```

## Usage Examples

### `vm` Command Completions
```bash
vm <TAB>                    # Shows: install list status create autostart start stop restart destroy delete console ip logs cleanup ssh
vm start <TAB>              # Shows available VM names
vm ssh <TAB>                # Shows available VM names
vm ssh myvm <TAB>           # Shows username completion (optional)
vm create --distro <TAB>    # Shows: ubuntu fedora arch debian
```

### `vm-create` Command Completions
```bash
vm-create --distro <TAB>           # Shows: ubuntu fedora arch debian
vm-create --memory <TAB>           # Shows: 1024 2048 4096 8192 16384
vm-create --vcpus <TAB>            # Shows: 1 2 4 8
vm-create --disk-size <TAB>        # Shows: 20G 40G 80G 100G
vm-create --dotfiles <TAB>         # Shows: min slim-shell shell dev box
vm-create --ssh-key <TAB>          # File path completion
```

## Troubleshooting

### Bash Completions Not Working
1. Ensure bash-completion is installed:
   ```bash
   # Ubuntu/Debian
   sudo apt install bash-completion

   # Fedora
   sudo dnf install bash-completion

   # Arch
   sudo pacman -S bash-completion
   ```

2. Check if completions are loaded:
   ```bash
   complete -p vm vm-create
   ```

3. Manually source the completion files:
   ```bash
   source share/completions/vm.bash
   source share/completions/vm-create.bash
   ```

### Zsh Completions Not Working
1. Ensure completion system is enabled in ~/.zshrc:
   ```bash
   autoload -U compinit && compinit
   ```

2. Check if functions are in fpath:
   ```bash
   echo $fpath
   ```

3. Rebuild completion cache:
   ```bash
   rm ~/.zcompdump*
   autoload -U compinit && compinit
   ```

### VM Names Not Completing
- Ensure `virsh` is installed and accessible
- Check if libvirt service is running:
  ```bash
  systemctl status libvirtd
  ```
- Verify you can list VMs manually:
  ```bash
  virsh list --all --name
  ```

## Notes

- Completions require the respective commands (`vm`, `vm-create`) to be in your PATH
- VM name completion requires `virsh` to be installed and functional
- Some completions provide suggested values but accept any input
- File path completions work with standard shell file completion
- The completions are designed to work with the current script interfaces and may need updates if the scripts change
