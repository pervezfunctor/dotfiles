# Development environment

## TLDR

On windows, use the following command and select what you want. DO NOT deselect preselected options.

**Important**: Run the following in powershell as administrator.

```powershell
iwr -useb https://dub.sh/NDyiu7a | iex
```

To configure your existing wsl distribution, use the following command in wsl(tumbleweed or ubuntu 24.04 recommended).

```bash
bash -c "$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)" -- wslbox
```

On linux desktop(or a desktop VM), install shell tools, vscode and docker.

```bash
bash -c "$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)" -- dev
```

In development container/vm/desktop, install modern unix tools using the following command. Works on linux and macos.

```bash
bash -c "$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)" -- shell
```

On macos, install essential apps along with shell tools. Works on linux too.

```bash
bash -c "$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)" -- desktop
```


## Recommended Setup


### ublue

Install and configure shell tools and desktop apps using the following command. Works only on bluefin and aurora.

```bash
bash -c "$(curl -sSL https://dub.sh/Hr0YTqp || wget -qO- https://dub.sh/Hr0YTqp)"
```

If you are an experienced linux user and and an experienced developer, then [Bluefin](https://projectbluefin.io) or [Aurora](https://getaurora.dev/en) would be perfect. Bluefin and Aurora are based on Fedora Atomic, an immutable(image based) distribution.

#### Recommendations

  - Install shell tools using [homebrew](https://brew.sh), which is comparable to `nix` or `aur` in package selection. You also get the latest versions of packages.

  - Install desktop apps using [flatpak](https://flathub.org), most modern apps on linux are available.

  - [Visual studio code](https://code.visualstudio.com) is installed and configured properly.

  - Use [docker](https://docker.com) or [podman](https://podman.io)(open source) for containers.

  - Use [distrobox](https://distrobox.it)(stateful and not isolated) for software development. You could use scripts from [Alternate setup](https://github.com/pervezfunctor/dotfiles/blob/main/docs/alternate-setup.md#alternate-setup) to setup the container.

  - Use [libvirt](https://libvirt.org)/[virt-manager](https://virt-manager.org) for virtual machines.

  - Or use [incus](https://linuxcontainers.org/incus) for both virtual machines and [lxc(stateful)](https://linuxcontainers.org/lxc) isolated and stateful containers.


### Fedora Atomic

If you prefer Fedora Atomic([Kinoite](https://fedoraproject.org/atomic-desktops/kinoite) or [Silverblue](https://fedoraproject.org/atomic-desktops/kinoite)), then use the following command. If you prefer a tiling window manager, then [Fedora Sway Atomic](https://fedoraproject.org/atomic-desktops/sway) is an excellent option.

```bash
bash -c "$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)" -- fedora-atomic
```

#### Recommendations

  - Use [distrobox](https://distrobox.it) for everything. Default distrobox is setup with zsh and shell utilies, gnome-keyring, visual studio code and firefox(needed for authentication).

  - You can also install visual studio code using flatpak.

  - Use [Ptyxis](https://gitlab.gnome.org/chergert/ptyxis) terminal, as it has great support for toolbox.

  - Use [Boxes](https://github.com/boxes-project/boxes) for virtual machines. Remember to enable 3d acceleration.


### Linux Desktop

This should work on almost any linux system. Doesn't need sudo privileges.

```bash
bash -c "$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)" -- nosudo
```
