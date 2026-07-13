# Windows development setup

`windows-setup-dev.ps1` installs and configures a Windows development environment. It can run interactively or install a specified set of components without showing the menu.

## Prerequisites

- The script requests administrator elevation automatically when necessary. You can also start it from an elevated PowerShell session.
- Ensure [Windows Package Manager (`winget`)](https://learn.microsoft.com/windows/package-manager/winget/) is available. Most application and development-tool components use it.
- Use a local checkout when possible. The script can then elevate itself and can be rerun after a restart.

PowerShell evaluates its execution policy before the script can run. If scripts are disabled, allow them for the current terminal session only:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

This does not permanently change the user or system execution policy.

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

For example, `wsl-ubuntu` automatically installs `wsl` first, while `dotfiles` and `capslock` automatically obtain the dotfiles source first. VS Code installs independently and applies the repository's extension list when the dotfiles source is available.

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
| `sudo` | Enables native Sudo for Windows in inline mode on Windows 11 24H2 or newer. | — |
| `dotfiles` | Clones or updates the dotfiles repository and applies its Windows configuration. | `dotfiles-source` |
| `capslock` | Imports the registry mapping that remaps Caps Lock to Control. | `dotfiles-source` |
| `nerd-fonts` | Installs the JetBrains Mono Nerd Font, using Chocolatey when necessary. | — |
| `vscode` | Installs Visual Studio Code and applies the repository's WSL extension list when available. | — |
| `devtools` | Installs command-line development tools, Microsoft Coreutils, PSScriptAnalyzer, Google Chrome, and the C/C++ build toolchain. | — |
| `ai-tools` | Installs the configured AI developer tools. | — |
| `apps` | Installs GlazeWM, Unity Hub, Slack, Telegram, Zed, Zoom, and Signal. | — |
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

`dotfiles-source` is an internal dependency, not a selectable menu item. It installs Git if necessary and clones the repository to `%USERPROFILE%\.ilm`. A clean checkout is updated when possible; a dirty checkout or an update failure produces a warning and continues using the existing local files.

## Restarts and reruns

Some work requires a restart, especially enabling WSL/Hyper-V features, installing Multipass, applying Windows updates, or remapping Caps Lock. When prompted, restart and run the script again to continue with any remaining components.

Installation is designed to be safe to rerun: `winget` packages already present are reported instead of reinstalled, existing WSL distributions are skipped, and local dotfiles changes are preserved. The script prints a grouped setup summary at the end, including installed, already-present, skipped, and failed results.

## One-line download option

[`windows-setup-dev-onliner.ps1`](windows-setup-dev-onliner.ps1) contains a download-and-run command for the development setup script. Run that command only from an elevated PowerShell session; a checked-out local script remains the preferred route because it supports automatic elevation and is easier to rerun after restart.
