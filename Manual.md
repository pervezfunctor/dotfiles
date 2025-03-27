# Manual Installation Instructions

## Initial set of instructions


### Windows

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
Similarly you could also install Tumbleweed

   ```powershell
   wsl --install -d openSUSE-Tumbleweed
   ```

5. If you need CentOS Stream, follow the instruction at [here](https://sigs.centos.org/altimages/wsl-images/).

6. Install [nerd fonts](https://github.com/ryanoasis/nerd-fonts). You could install them with chocolatey.

   ```powershell
   choco install nerd-fonts-jetbrainsmono
   ```
You could install chocolatey with the following command.

   ```powershell
   winget install chocolatey.chocolatey
   ```

7. Set your windows terminal to use nerd fonts.

8. Follow the linux instructions below for almost everything.


### MACOS

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

1. There are lot's of linux distributions. If you want to use OS package manager for most things, then use `Fedora` or `Tumbleweed`. Your base linux doesn't matter much if you use `distrobox` or `toolobox` or `devcontainers`, in which case `Ubuntu` or `CentOS Stream` is fine.

2. Install essential packages. Following will work on `Ubuntu`.

   ```bash
   sudo apt-get update && sudo apt-get upgrade -y
   sudo apt-get install -y curl wget git-core trash-cli
   sudo apt-get install -y tar unzip cmake build-essential
   ```

On `OpenSuse Tumbleweed`

```bash
sudo zypper refresh && sudo zypper dup
sudo zypper in neovim gcc make ripgrep fd fzf starship zsh tmux trash-cli curl
sudo zypper in wget stow cmake tar unzip git-core autoconf automake binutils
sudo zypper in expect flex bison glibc-devel
```

If you are using OS other than `Ubuntu` then you need to make sure git, wget, curl, trash-cli, unzip, tar, python, perl and all C development tools like gcc and make are installed.

3. Install homebrew. Optional on Tumbleweed.

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

8. Set Ptyxis font to `JetbrainsMono Nerd Font`. Pick your favorite theme.

9. Definitely use either [distrobox](https://github.com/89luca89/distrobox) or [toolbox](https://github.com/containers/toolbox) for software development. [devcontainers](https://code.visualstudio.com/docs/devcontainers/containers) is also a good choice.


## TMUX

1. Install tmux with your package manager.

   ```bash
   sudo apt-get install -y tmux # or
   brew install tmux
   ```

Setup configuration with

   ```bash
   cd ~/.ilm
   stow tmux
   ```


## ZSH

1. Install zsh with your package manager.

   ```bash
   sudo apt-get install -y zsh # or
   brew install zsh
   ```
2. Install starship with your package manager.

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
   sudo apt-get install -y neovim # or
   brew install neovim
   ```

2. Setup [Astronvim](https://docs.astronvim.com/) or [LazyVim](https://lazyvim.github.io/) with


## VSCODE

1. Install vscode with your package manager.

   ```bash
   winget install Microsoft.VisualStudioCode # on windows only
   brew install --cask visual-studio-code # on macos only
   ```

On Linux, follow the instruction [here](https://code.visualstudio.com/docs/setup/linux).

2. Look at [minimal-settings.json](extras/vscode/minimal-settings.json) and [common extensions](extras/vscode/extensions/common).

3. On Windows, make sure you have neovim extension installed and have the following in settings.json

   ```json
   "remote.extensionKind": {
       "asvetliakov.vscode-neovim": ["workspace"]
   }
   ```


## Additional Modern Linux Tools

Some modern linux/macos tools

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

Consider `multipass` for virtualization. It allows you to create and destroy Ubuntu VMs very easily.
