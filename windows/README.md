# Windows development setup

`windows-setup-dev.ps1` installs and configures a Windows development environment. It can run interactively or install a specified set of components without showing the menu.

## Prerequisites

- Run the script from an **elevated PowerShell session** (Run as administrator). If it is started from a file without elevation, it requests elevation and reruns itself.
- Ensure [Windows Package Manager (`winget`)](https://learn.microsoft.com/windows/package-manager/winget/) is available. Most application and development-tool components use it.
- Use a local checkout when possible. The script can then elevate itself and can be rerun after a restart.

The script changes the execution policy for its own PowerShell process only when needed, then restores the original process policy when it finishes.

## Run it

From the repository root in an elevated PowerShell session:

```powershell
.\windows\windows-setup-dev.ps1
```

This opens the component menu with these selections enabled by default:

- `nerd-fonts`
- `vscode`
- `wsl`
- `wsl-ubuntu-26.04`

Use numbers to toggle menu entries, `a` to select all visible entries, `n` to clear the selection, `d` (or Enter) to start, and `q` to quit without making changes.

### List components

```powershell
.\windows\windows-setup-dev.ps1 -ListComponents
```

### Install selected components

Pass one or more component names to skip the interactive menu. Dependencies are included automatically and run before the selected component.

```powershell
.\windows\windows-setup-dev.ps1 -Components wsl,devtools,nerd-fonts
```

For example, `wsl-ubuntu` automatically installs `wsl` first, and `dotfiles`, `capslock`, and `vscode` automatically obtain the dotfiles source first.

### Install all components

```powershell
.\windows\windows-setup-dev.ps1 -Components all
```

`all` includes the standard component set, but excludes the internal `dotfiles-source` dependency and the optional `wsl-ubuntu-26.04` image installer. Select `wsl-ubuntu-26.04` explicitly when needed.

## Components

| Component | What it does | Automatically includes |
| --- | --- | --- |
| `windows-update` | Checks for and installs Windows updates. | — |
| `debloat` | Downloads and runs the Windows debloat script after confirmation. | — |
| `dotfiles` | Clones or updates the dotfiles repository and applies its Windows configuration. | `dotfiles-source` |
| `capslock` | Imports the registry mapping that remaps Caps Lock to Control. | `dotfiles-source` |
| `nerd-fonts` | Installs the JetBrains Mono Nerd Font, using Chocolatey when necessary. | — |
| `vscode` | Installs Visual Studio Code and the repository's WSL extension list. | `dotfiles-source` |
| `devtools` | Installs command-line development tools and the C/C++ build toolchain. | — |
| `ai-tools` | Installs the configured AI developer tools. | — |
| `apps` | Installs the configured desktop applications. | — |
| `wsl` | Enables Hyper-V, WSL, and related Windows features. | — |
| `multipass` | Installs Multipass. | — |
| `multipass-vm` | Configures SSH access for the Multipass VM. | `multipass` |
| `wsl-ubuntu` | Installs Ubuntu 26.04 through WSL. | `wsl` |
| `wsl-debian` | Installs Debian through WSL. | `wsl` |
| `wsl-opensuse` | Installs openSUSE Tumbleweed through WSL. | `wsl` |
| `wsl-fedora` | Installs Fedora Linux 44 through WSL. | `wsl` |
| `wsl-centos` | Imports and initializes CentOS Stream 10 for WSL. | `wsl` |
| `wsl-nixos` | Installs and updates NixOS on WSL. | `wsl` |
| `wsl-ubuntu-26.04` | Downloads and installs the Ubuntu 26.04 WSL image. | `wsl` |

`dotfiles-source` is an internal dependency, not a selectable menu item. It installs Git if necessary and clones the repository to `%USERPROFILE%\.ilm`, or updates that checkout when it has no uncommitted changes.

## Restarts and reruns

Some work requires a restart, especially enabling WSL/Hyper-V features, installing Multipass, applying Windows updates, or remapping Caps Lock. When prompted, restart and run the script again to continue with any remaining components.

Installation is designed to be safe to rerun: `winget` packages already present are reported instead of reinstalled, existing WSL distributions are skipped, and the dotfiles checkout is updated only when clean. The script prints a grouped setup summary at the end, including installed, already-present, skipped, and failed results.

## One-line download option

[`windows-setup-dev-onliner.ps1`](windows-setup-dev-onliner.ps1) contains a download-and-run command for the development setup script. Run that command only from an elevated PowerShell session; a checked-out local script remains the preferred route because it supports automatic elevation and is easier to rerun after restart.
