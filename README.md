# Development environment

## TLDR


If within a linux development container, or just want all of the modern unix tools, use the following command.

```bash
bash -c "$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)" -- shell
```

On linux desktop(or a GUI VM(vmware/virtualbox for eg)), to get started quickly, use the following command.

```bash
bash -c "$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)" -- dev
```

On windows, use the following command, select what you want. DO NOT deselect preselected options.

iwr -useb https://dub.sh/NDyiu7a | iex


## Recommended Setup


### ublue

If you are an experienced linux user and and an experienced developer, then [Aurora](https://getaurora.dev/en) or [Bluefin](https://projectbluefin.io) would be perfect. Bluefin and Aurora are based on Fedora Atomic.

  - Install shell tools using [homebrew](https://brew.sh), which is comparable to `nix` or `aur` in package selection. You also get the latest versions of packages.

  - Install desktop apps using [flatpak](https://flathub.org), most modern apps on linux are available.

  - [Visual studio code](https://code.visualstudio.com) is installed and configured properly.

  - Use [docker](https://docker.com) or [podman](https://podman.io)(open source) for containers.

  - Use [distrobox](https://distrobox.it) for software development. You could use scripts from [Alternate setup](#alternate-setup) to setup the container.

  - [libvirt](https://libvirt.org)/[virt-manager](https://virt-manager.org) for virtual machines.

  - [incus](https://linuxcontainers.org/incus) for virtual machines and [lxc(stateful)](https://linuxcontainers.org/lxc) containers.

Install and configure shell tools and desktop apps using the following command. Works only on bluefin and aurora.

```bash
bash -c "$(curl -sSL https://dub.sh/Hr0YTqp || wget -qO- https://dub.sh/Hr0YTqp)"
```


### Fedora Atomic

If you prefer Fedora Atomic([Kinoite](https://fedoraproject.org/atomic-desktops/kinoite) or [Silverblue](https://fedoraproject.org/atomic-desktops/kinoite)), then use the following command. If you prefer an immutable OS along with a tiling window manager, then [Fedora Sway Atomic](https://fedoraproject.org/atomic-desktops/sway) is an excellent option.

```bash
bash -c "$(curl -sSL https://dub.sh/RCrpnUm || wget -qO- https://dub.sh/RCrpnUm)"
```

  - Use [distrobox](https://distrobox.it) for everything. Default distrobox is setup with zsh and shell utilies, gnome-keyring, visual studio code and firefox(needed for authentication).

  - You can also install visual studio code using flatpak.

  - Use [Ptyxis](https://gitlab.gnome.org/chergert/ptyxis) terminal, as it has great support for toolbox.
