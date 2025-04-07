# Minimal Installation Instructions

## Windows

1. Make sure you have latest windows 11 updates.

2. Make sure you have winget.

3. Install the following packages using winget.

   ```powershell
   winget install Git.Git
   winget install GitHub.cli
   winget install Microsoft.VisualStudioCode
   ```

4. All your development could happen in `wsl`. Install `wsl` with the following command.

   ```powershell
   wsl --install -d Ubuntu-24.04
   ```

   Similarly you could also install Tumbleweed(Recommended).

   ```powershell
   wsl --install -d openSUSE-Tumbleweed
   ```

5. If you need CentOS Stream, follow the instruction at [here](https://sigs.centos.org/altimages/wsl-images/).

6. Install [nerd fonts](https://github.com/ryanoasis/nerd-fonts). You could install them with [chocolatey](https://chocolatey.org/install).

   ```powershell
   choco install nerd-fonts-jetbrainsmono
   ```

   You could install chocolatey with the following command.

   ```powershell
   winget install chocolatey.chocolatey
   ```

7. Set your windows terminal to use nerd fonts. Press `Ctrl+,` and set font to `JetbrainsMono Nerd Font` for `CentOS-Stream-10` and `Powershell` profiles or preferably in defaults profile.

8. Follow the linux and vscode instructions below.

## MACOS

1. Install xcode command line tools

   ```bash
   xcode-select --install
   ```

2. Install homebrew

   ```bash
   NONINTERACTIVE=1 /bin/bash -c "$(curl -sSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

3. Install essential packages

   ```bash
   brew install curl wget trash tree unzip coreutils gum stow
   ```

4. Install ghostty and nerd fonts with brew.

   ```bash
   brew install ghostty
   brew tap homebrew/cask-fonts
   brew install --cask font-jetbrains-mono-nerd-font
   ```

5. Clone this repository.

   ```bash
   git clone https://github.com/pervezfunctor/dotfiles.git ~/.ilm
   ```

6. Setup ghostty configuration

   ```bash
   cd ~/.ilm
   stow ghostty
   ```

7. If you like tiling window manager, try [aerospace](https://github.com/nikitabobko/AeroSpace). Install it using the following command.

   ```bash
   brew tap nikitabobko/tap
   brew install nikitabobko/tap/aerospace
   ```

8. Setup aerospace configuration

   ```bash
   cd ~/.ilm
   stow aerospace
   ```

9. For Containers/Virtual machines, try [orbstack](https://orbstack.dev/) or [colima](https://github.com/abiosoft/colima) or [UTM](https://mac.getutm.app/)

### Linux

1. Install base system packages and configure this repository using the following command on linux or macos.

   ```bash
   bash -c "$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)" -- min
   ```

2. Install essential packages. Following will work on `Ubuntu`.

   ```bash
   sudo apt-get update && sudo apt-get upgrade -y
   sudo apt-get install -y curl wget git-core trash-cli
   sudo apt-get install -y tar unzip build-essential
   ```

On `Fedora`

```bash
sudo dnf update -y
sudo dnf install -y curl wget git-core trash-cli
sudo dnf install -y tar unzip gcc make
```

On Tumbleweed

```bash
sudo zypper refresh && sudo zypper dup
sudo zypper in neovim gcc make ripgrep fd fzf starship zsh tmux trash-cli curl
sudo zypper in wget stow tar unzip git-core autoconf automake binutils
sudo zypper in expect flex bison glibc-devel
```

On `OpenSuse Tumbleweed`

```bash
sudo zypper refresh && sudo zypper dup
sudo zypper in neovim gcc make ripgrep fd fzf starship zsh tmux trash-cli curl
sudo zypper in wget stow cmake tar unzip git-core autoconf automake binutils
sudo zypper in expect flex bison glibc-devel
```

If you are using OS other than `Ubuntu` then you need to make sure git, wget, curl, trash-cli, unzip, tar, python, perl and all C development tools like gcc and make are installed.

3. Install homebrew. Optional on Tumbleweed/Fedora.

   ```bash
   NONINTERACTIVE=1 /bin/bash -c "$(curl -sSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

4. Install essential packages with homebrew

   ```bash
   brew install gum stow
   ```

5. Clone this repository.

   ```bash
   git clone https://github.com/pervezfunctor/dotfiles.git ~/.ilm
   ```

Following steps only for Linux Desktop.

6. Install Ptyxis using `flatpak`(`flathub`).

   ```bash
   flatpak install -y --user flathub app.devsuite.Ptyxis
   ```

For flatpak/flathub setup, follow the instructions [here](https://flathub.org/setup).

7. Install nerd fonts

   ```bash
   brew tap homebrew/cask-fonts
   brew install --cask font-jetbrains-mono-nerd-font
   ```

8. Set Ptyxis font to `JetbrainsMono Nerd Font`. Pick your favorite theme(Checkout Catpuccin Mocha, Tokyo Night, Everforest).

9. Use one of [devcontainers](https://code.visualstudio.com/docs/devcontainers/containers), [distrobox](https://github.com/89luca89/distrobox), [toolbox](https://github.com/containers/toolbox) for software development.

## TMUX

1. Install tmux with your package manager. For example

   ```bash
   sudo apt-get install -y tmux # Ubuntu
   sudo dnf install -y tmux # Fedora/CentOS
   sudo zypper install -y tmux # Opensuse Tumbleweed
   brew install tmux # macos and linux
   ```

Setup configuration with

```bash
cd ~/.ilm
stow tmux
```

## ZSH

1. Install zsh with your package manager.

   ```bash
   sudo apt-get install -y zsh # Ubuntu
   sudo dnf install -y zsh # Fedora/CentOS
   sudo zypper install -y zsh # Opensuse Tumbleweed
   brew install zsh # macos and linux
   ```

2. Install [starship](https://starship.rs/) with your package manager.

   ```bash
   curl -sS https://starship.rs/install.sh | sh -s -- -y -b ~/.local/bin
   ```

3. Setup configuration with

   ```bash
   cd ~/.ilm
   stow zsh
   ```

## Neovim

1. Install neovim with your package manager.

   ```bash
   brew install neovim # latest neovim on macos/linux
   sudo apt-get install -y neovim # Ubuntu. This could be old, not recommended.
   sudo dnf install -y neovim # Fedora/CentOS
   sudo zypper install -y neovim # Opensuse Tumbleweed
   ```

2. Setup [Astronvim](https://docs.astronvim.com/) or [LazyVim](https://lazyvim.github.io/) following instructions at official website. Or run the following command for lightly modified versions.

   ```bash
   cd ~/.ilm
   stow nvim # for lazyvim
   stow astro # for astronvim
   ```

## VSCODE

1. Install vscode with your package manager.

   ```bash
   winget install Microsoft.VisualStudioCode # on windows only
   brew install --cask visual-studio-code # on macos only
   ```

On Linux, follow the instruction [here](https://code.visualstudio.com/docs/setup/linux).

2. Look at [minimal-settings.json](extras/vscode/minimal-settings.json) and [common extensions](extras/vscode/extensions/common). At the least install remote extensions(and wsl on windows).

   ```bash
   code --install-extension ms-vscode-remote.remote-containers
   code --install-extension ms-vscode-remote.remote-ssh
   code --install-extension ms-vscode-remote.remote-ssh-edit
   code --install-extension ms-vscode.remote-explorer
   code --install-extension ms-vscode-remote.remote-wsl # on windows only
   ```

3. On Windows, make sure you have neovim extension installed(if you need neovim and vscode integration) and have the following in settings.json.

   ```json
   "remote.extensionKind": {
       "asvetliakov.vscode-neovim": ["workspace"]
   }
   ```

## Additional Modern Linux Tools

Pick your favorite modern linux/macos tools

```bash
brew install tree-sitter gh gum stow tmux carapace lazygit eza fzf fd zoxide
brew install git-delta yazi ripgrep bat ugrep micro carapace nushell
brew install jq just shfmt shellcheck lazydocker broot dust htop dysk
brew install cheat curlie duf sd xh doggo atuin procs hyperfine pixi
brew install yq yazi superfile gdu tealdeer choose-rust bottom television
```

Some modern tools for windows

```powershell
winget install --id dandavison.delta -e
winget install --id wez.wezterm -e
winget install --id BurntSushi.ripgrep.MSVC -e
winget install --id junegunn.fzf -e
winget install --id Nushell.Nushell -e
winget install --id 7zip.7zip -e
winget install --id Microsoft.VisualStudioCode -e
winget install --id Mozilla.Firefox -e
winget install --id Git.Git -e
winget install --id wez.wezterm -e
winget install --id Docker.DockerDesktop -e
winget install --id BurntSushi.ripgrep -e
winget install --id junegunn.fzf -e
winget install --id sharkdp.fd -e
winget install --id sharkdp.bat -e
winget install --id GitHub.cli -e
winget install --id dandavison.delta -e
winget install --id astral-sh.uv -e
winget install --id jesseduffield.lazygit -e
winget install --id jesseduffield.lazydocker -e
winget install --id Neovim.Neovim -e
winget install --id Starship.Starship
winget install --id ajeetdsouza.zoxide -e
winget install --id rsteube.Carapace -e
winget install --id glazewm.glazewm -e
winget install --id Telegram.TelegramDesktop -e
winget install --id Zoom.Zoom -e
winget install --id OpenWhisperSystems.Signal -e
winget install --id Canonical.Multipass -e
```

Consider `multipass` for virtualization. It allows you to create and destroy Ubuntu VMs very easily. I use [incus](https://linuxcontainers.org/incus) instead of `multipass` for virtualization.
