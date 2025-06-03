# Development environment

## Installation on your current system


### Windows

On windows, use WSL. Install WSL, use  the following command.

```powershell
wsl --install --no-distribution
```

I recommend fedora for development. You could also use Ubuntu 24.04.

```powershell
wsl --list --online # Pick any from here in the following command.
wsl --install FedoraLinux-42
wsl -d FedoraLinux-42 # Create user and set a password.
```

Run the following command in WSL for installing basic tools and a nice shell prompt. Make sure you are not root.

```bash
bash -c "$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)" -- wslbox
```

Exit and enter WSL again(or reboot) to install more development tools.

```bash
ilmi tmux nvim emacs # pick any
```

If you want to setup vscode and other development tools on Windows, run the following command in powershell **as administrator**.

```powershell
iwr -useb https://dub.sh/NDyiu7a | iex
```

You will be presented with a menu, pick what you want to install.


### MACOS

On macos, install applications(vscode, ghostty terminal, fonts etc) along with shell tools. Works on linux too.

```bash
bash -c "$(curl -sSL https://dub.sh/aPKPT8V)" -- desktop
```

If you just want homebrew and basic unix tools, run the following command.

```bash
bash -c "$(curl -sSL https://dub.sh/aPKPT8V)"
```

### Linux

On linux desktop(Ubuntu 25.04 for eg), install shell tools, vscode and docker with the following command. Works on Ubuntu 25.04, Fedora 42, OpenSUSE Tumbleweed, CentOS Stream 10 and Arch.

```bash
bash -c "$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)" -- dev
```

If you only want to install modern unix tools in a development container/vm/desktop, use the following command instead. Works on linux and macos.

```bash
bash -c "$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)" -- shell
```

Or just install the very basic packages(gcc, make, tar, git etc)

```bash
bash -c "$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)"
```


## Recommended Setup

### Fedora Atomic

If ublue is not stable enough or if you prefer an official Fedora distribution, use Fedora Atomic.

  - [Silverblue](https://fedoraproject.org/atomic-desktops/silverblue) with gnome 48 is a great choice.
  - [Kinoite](https://fedoraproject.org/atomic-desktops/kinoite) if you prefer KDE.
  - [Fedora Sway Atomic](https://fedoraproject.org/atomic-desktops/sway) if you prefer a tiling window manager

```bash
bash -c "$(curl -sSL https://dub.sh/aPKPT8V)" -- fedora-atomic
```

#### Recommendations

  - Use [distrobox](https://distrobox.it) for everything. Default distrobox is setup with zsh and shell utilities, gnome-keyring, vscode and firefox.

  - Use [Ptyxis](https://gitlab.gnome.org/chergert/ptyxis) terminal, as it has great support for distrobox and toolbox.

  - Use [Boxes](https://apps.gnome.org/Boxes) for simple virtual machines. Remember to enable 3d acceleration.


In future, I will add a distrobox container for docker, incus and libvirt. Currently with the above setup, you won't have docker. You could install ubuntu server in vm and configure docker there.


### Linux Desktop

This should work on almost any linux system/container even without sudo privilege; You should have curl/wget and bash installed. Not recommended on macos.

```bash
bash -c "$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)" -- generic
```


## Linux Development Container/VM

Install essential tools and bash config with

```bash
bash -c "$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)" -- slimbox
```

You could later install additional development tools with

```bash
ilmi zsh tmux nvim emacs # pick any
```

If you are in distrobox or a virtual machine with desktop environment, you could install terminal with

```bash
ilmi terminal
```

You might be able to install vscode with

```bash
ilmi vscode
```
