
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


#### Recommendations

  - Install shell tools using [homebrew](https://brew.sh), which is comparable to `nix` or `aur` in package selection. You generally get the latest versions of packages.

  - Install desktop apps using [flatpak](https://flathub.org), most modern apps on linux are available. Use Software on Gnome and Discover on KDE. These should be preinstalled on your system.

  - [Visual studio code](https://code.visualstudio.com) is installed and configured properly. You could install neovim extension, to use your neovim configuration and keybindings in `vscode`.

  - Use [docker](https://docker.com) or [podman](https://podman.io)(open source) for containers. DO NOT alias podman as docker.

  - Use [distrobox](https://distrobox.it)(stateful and not isolated) for software development. You could use scripts from [Alternate setup](https://github.com/pervezfunctor/dotfiles/blob/main/docs/alternate-setup.md#alternate-setup) to setup your container.

  - Use [libvirt](https://libvirt.org)/[virt-manager](https://virt-manager.org) for virtual machines.

  - Or use [incus](https://linuxcontainers.org/incus) for virtual machines and [lxc(stateful and isolated)](https://linuxcontainers.org/lxc) for containers. You need to run `ujust incus` before using incus.


Install and configure shell tools and common applications using the following command. This is optional.

```bash
bash -c "$(curl -sSL https://is.gd/hurace)"
```

