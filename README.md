# Development environment

## Installation on your current setup

On windows, use WSL. If already not installed, install wsl with the following command.

```powershell
wsl --install --no-distribution
```

I recommend fedora for development. Any other distribution should be fine too.

```powershell
wsl --list --online # Pick any from here in the following command.
wsl --install FedoraLinux-42
wsl -d FedoraLinux-42 # Create user and set a password.
```


```bash
bash -c "$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)" -- wslbox
```

If you want to setup vscode and other tools on Windows(11), use the following command instead.

**Important**: Run the following in powershell as administrator.

```powershell
iwr -useb https://dub.sh/NDyiu7a | iex
```

Setup any of your WSL distribution with the above bash script(wslbox).


On linux desktop(Ubuntu 25.04 for eg), install shell tools, vscode and docker. This should work on Ubuntu 25.04, Fedora 42, Tumbleweed, CentOS Stream 10 and Arch. This will also work on Debian trixie once that's released.

```bash
bash -c "$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)" -- dev
```

IF you only want to install modern unix tools in a development container/vm/desktop, use the following command instead. Works on linux and macos.

```bash
bash -c "$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)" -- shell
```

On macos, install common applications(vscode, ghostty terminal, fonts etc) along with shell tools. Works on linux too.

```bash
bash -c "$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)" -- desktop
```

Above script, especially on linux will take a long time.

## Recommended Setup


### ublue

Install and configure shell tools and common applications using the following command. Works only on bluefin and aurora.

```bash
bash -c "$(curl -sSL https://dub.sh/Hr0YTqp || wget -qO- https://dub.sh/Hr0YTqp)"
```

If you are an experienced linux user and and an experienced developer, then [Bluefin](https://projectbluefin.io) or [Aurora](https://getaurora.dev/en) would be perfect. Bluefin and Aurora are based on Fedora Atomic, an immutable(image based) distribution.

#### Recommendations

  - Install shell tools using [homebrew](https://brew.sh), which is comparable to `nix` or `aur` in package selection. You also get the latest versions of packages.

  - Install desktop apps using [flatpak](https://flathub.org), most modern apps on linux are available. Use Software on Gnome and Discover on KDE. These should be preinstalled.

  - [Visual studio code](https://code.visualstudio.com) is installed and configured properly. You could install neovim extension, to use your neovim configuration and keybindings in `vscode`.

  - Use [docker](https://docker.com) or [podman](https://podman.io)(open source) for containers. DO NOT alias podman as docker.

  - Use [distrobox](https://distrobox.it)(stateful and not isolated) for software development. You could use scripts from [Alternate setup](https://github.com/pervezfunctor/dotfiles/blob/main/docs/alternate-setup.md#alternate-setup) to setup your container.

  - Use [libvirt](https://libvirt.org)/[virt-manager](https://virt-manager.org) for virtual machines.

  - Or use [incus](https://linuxcontainers.org/incus) for virtual machines and [lxc(stateful)](https://linuxcontainers.org/lxc) containersisolated and stateful containers. You need to run `ujust incus`.


### Fedora Atomic

If ublue is not stable on your system or if you prefer Fedora official distributions, use Fedora Atomic.

  - [Silverblue](https://fedoraproject.org/atomic-desktops/silverblue)) with gnome 48 is a great choice.
  - [Kinoite](https://fedoraproject.org/atomic-desktops/kinoite if you prefer KDE.
  -  [Fedora Sway Atomic](https://fedoraproject.org/atomic-desktops/sway) if you prefer a tiling window manager

```bash
bash -c "$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)" -- fedora-atomic
```

#### Recommendations

  - Use [distrobox](https://distrobox.it) for everything. Default distrobox is setup with zsh and shell utilies, gnome-keyring, visual studio code and firefox(needed for authentication).

  - You can also install visual studio code using flatpak.

  - Use [Ptyxis](https://gitlab.gnome.org/chergert/ptyxis) terminal, as it has great support for toolbox.

  - Use [Boxes](https://apps.gnome.org/Boxes) for virtual machines. Remember to enable 3d acceleration.


### Linux Desktop

This should work on almost any linux system/container even without sudo privilege; You should have curl, bash, unzip and python3 are installed. Not recommended on macos.

```bash
bash -c "$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)" -- generic
```
