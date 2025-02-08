# Development environment

## Recommended Setup

### ublue

If you are an experienced linux user and and an experienced developer, then [Aurora](https://getaurora.dev/en) or [Bluefin](https://projectbluefin.io) would be perfect. Bluefin and Aurora are based on Fedora Atomic.

  - Install shell tools using [homebrew](https://brew.sh), which is comparable to `nix` or `aur` in package selection. You also get the latest versions of packages.
  - Install desktop apps using [flatpak](https://flathub.org), most modern apps on linux are available.
  - [Visual studio code](https://code.visualstudio.com) is installed and configured properly.
  - Use [podman](https://podman.io)(open source) for containers.
  - Use [distrobox](https://distrobox.it) for software development. You could use scripts from [Alternate setup](#alternate-setup) to setup the container.
  - [libvirt](https://libvirt.org)/[virt-manager](https://virt-manager.org) for virtual machines.
  - [incus](https://linuxcontainers.org/incus) for virtual machines and [lxc(stateful)](https://linuxcontainers.org/lxc) containers.

Install and configure shell tools and desktop apps using the following command. Works only or bluefin and aurora.

```bash
bash -c "$(curl -sSL https://dub.sh/Hr0YTqp || wget -qO- https://dub.sh/Hr0YTqp)"
```


### Fedora Atomic

If you prefer Fedora Atomic([Kinoite](https://fedoraproject.org/atomic-desktops/kinoite) or [Silverblue](https://fedoraproject.org/atomic-desktops/kinoite)), then use the following command. If you prefer an immutable OS along with a tiling window manager, then [Fedora Sway Atomic](https://fedoraproject.org/atomic-desktops/sway) is an excellent option.

You might be missing some packages as `rpm-ostree` is NOT used for installing any packages. `mise` is used instead of `homebrew` for this setup. `flatpak` version of vscode is installed.

```bash
bash -c "$(curl -sSL https://dub.sh/RCrpnUm || wget -qO- https://dub.sh/RCrpnUm)"
```

 Don't install everything on the host. Use [toolbox](https://docs.fedoraproject.org/en-US/fedora-silverblue/toolbox) for almost everything. You can Install `visual studio code` inside a `toolbox` container. [Ptyxis](https://gitlab.gnome.org/chergert/ptyxis) terminal has great support for toolbox.

### Vanilla OS

I have not looked at `Vanilla OS` yet, as it's not stable in a virtual machine for me.


## Alternate setup

**Note**: All of the following scripts should work fine on most flavors of `Ubuntu`, `Fedora`(Not Atomic), `Debian`, `Arch` and `Opensuse Tumbleweed`.

If you are a beginner linux developer, look at [Rhino Linux](https://rhinolinux.org), an ubuntu based rolling release. It's an ubuntu XFCE distribution. Make sure you select container and virtualization tools in the post install dialog.

If you are an experienced linux developer, but don't want to use immutable distributions, I would recommend Opensuse Tumbleweed, a rolling release, similar to Arch Linux, simpler and more stable. You could always use Arch Linux, but do not that it's not for the faint hearted.

Install and configure shell tools with the following command.
```bash

bash -c "$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)" -- shell
```
Install container and virtualization tools in addition to above shell tools and configuration, with following command.

```bash
bash -c "$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)" -- vm
```
Install desktop apps including vscode, with the following command.

```bash
bash -c "$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)" -- desktop
```

You could also, first install the base setup

```bash
bash -c "$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)"
```

and then at any point(after reboot), use `group-installer`.

```bash
group-installer
group-installer help
```

You could pick from `shell`, `ct`, `vm`, `desktop` and `all` groups.

`shell` will install and configure bash, zsh(shells with [starship](https://starship.rs) prompt), neovim(with [astronvim](https://astronvim.com)) and [tmux](https://github.com/tmux/tmux/wiki). Installs modern shell tools like

- [gh - github cli](https://cli.github.com)
- [just - task runner](https://github.com/casey/just)
- [fzf - fuzzy finder](https://github.com/junegunn/fzf)
- [zoxide - smart cd](https://github.com/ajeetdsouza/zoxide)
- [fd - find](https://github.com/sharkdp/fd)
- [eza - modern ls](https://github.com/eza-community/eza)
- [bat - modern cat](https://github.com/sharkdp/bat)
- [delta - git diff](https://github.com/dandavison/delta)
- [procs - modern ps](https://github.com/dalance/procs)
- [sd - modern sed](https://github.com/chmln/sd)
- [xh - modern httpie](https://github.com/ducaale/xh)
- [bottom - modern top](https://github.com/ClementTsang/bottom)
- [duf - modern df](https://github.com/muesli/duf)
- [cheat - cheat sheet](https://github.com/cheat/cheat)
- [lazygit - git ui](https://github.com/jesseduffield/lazygit)

`ct` will install the following, along with `shell` packages above.

- [docker](https://docker.com)
- [portainer](https://portainer.io)
- [lazydocker](https://github.com/jesseduffield/lazydocker)
- [podman](https://podman.io)
- [incus](https://linuxcontainers.org/incus)

`desktop` will install the following, along with `shell` packages above.

- [ghostty terminal](https://github.com/pgdev92/ghostty) or [wezterm](https://wezfurlong.org/wezterm)
- [vscode editor](https://code.visualstudio.com)
- [nerd fonts for jetbrains mono, cascadia code mono](https://github.com/ryanoasis/nerd-fonts)
- apps(telegram, [zoom](https://zoom.us), [obsidian](https://obsidian.md), chromium etc)

In addition to the above group installs, you could also use `installer` to setup various tools like `emacs`.

```bash
installer
```
To get all options and short descriptions, run

```bash
installer help
```

## Container Setup

Most development should happen in a container, either in a [devcontainer](https://code.visualstudio.com/docs/devcontainers/containers) or in a [distrobox](https://github.com/89luca89/distrobox). You could use the same scripts as above to setup shell.

For most development tools, use could use [mise](https://mise.dev). For python just use `uv`.

You could also install necessary tools and libraries for rust, go, c++ development using `installer`.

```bash
installer rust
installer go
installer cpp
```
