# Development environment

## Installation on your current system


### Windows

On windows, use WSL. If not installed, install with the following command.

```powershell
wsl --install --no-distribution
```

I recommend fedora for development. You could also use Ubuntu 24.04.

```powershell
wsl --list --online # Pick any from here in the following command.
wsl --install FedoraLinux-42
wsl -d FedoraLinux-42 # Create user and set a password.
```

Run the following command in WSL for installing basic tools and a nice shell prompt.

```bash
bash -c "$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)" -- wslbox
```
Exit and enter WSL again to install few more tools of your choice.

```bash
ilm-installer tmux nvim emacs # pick any
```

If you want to setup vscode and other tools on Windows, run the following command in powershell **as administrator**.

```powershell
iwr -useb https://dub.sh/NDyiu7a | iex
```

You will be presented with a menu, pick what you want to install.


### MACOS

On macos, install applications(vscode, ghostty terminal, fonts etc) along with shell tools. Works on linux too.

```bash
bash -c "$(curl -sSL https://dub.sh/aPKPT8V)" -- desktop
```

If you just homebrew and basic unix tools.

```bash
bash -c "$(curl -sSL https://dub.sh/aPKPT8V)"
```


### Linux

On linux desktop(Ubuntu 25.04 for eg), install shell tools, vscode and docker with the following command. Ubuntu 25.04, Fedora 42, OpenSUSE Tumbleweed, CentOS Stream 10 and Arch are supported.

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


### ublue(Aurora/Bluefin)

First, update your system.

```bash
ujust update
```

For a good terminal experience(nice prompt), run the following command.

```bash
ujust bluefin-cli # on Bluefin
ujust aurora-cli # on Aurora
```

If you are an experienced linux user and and an experienced developer, then [Bluefin](https://projectbluefin.io) or [Aurora](https://getaurora.dev/en) would be perfect. Bluefin and Aurora are based on Fedora Atomic, an immutable(image based) distribution.

#### Recommendations

  - Install shell tools using [homebrew](https://brew.sh), which is comparable to `nix` or `aur` in package selection. You also get the latest versions of packages.

  - Install desktop apps using [flatpak](https://flathub.org), most modern apps on linux are available. Use Software on Gnome and Discover on KDE. These should be preinstalled.

  - [Visual studio code](https://code.visualstudio.com) is installed and configured properly. You could install neovim extension, to use your neovim configuration and keybindings in `vscode`.

  - Use [docker](https://docker.com) or [podman](https://podman.io)(open source) for containers. DO NOT alias podman as docker.

  - Use [distrobox](https://distrobox.it)(stateful and not isolated) for software development. You could use scripts from [Alternate setup](https://github.com/pervezfunctor/dotfiles/blob/main/docs/alternate-setup.md#alternate-setup) to setup your container.

  - Use [libvirt](https://libvirt.org)/[virt-manager](https://virt-manager.org) for virtual machines.

  - Or use [incus](https://linuxcontainers.org/incus) for virtual machines and [lxc(stateful and isolated)](https://linuxcontainers.org/lxc) for containers. You need to run `ujust incus`.


Install and configure shell tools and common applications using the following command. This is optional.

```bash
bash -c "$(curl -sSL https://dub.sh/Hr0YTqp)"
```


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
ilm-installer zsh tmux nvim emacs # pick any
```

If you are in distrobox or a virtual machine with desktop environment, you could install terminal with

```bash
ilm-installer terminal
```

You might be able to install vscode with

```bash
ilm-installer vscode
```
