#  Development environment

### Recommended Setup

If you are an experienced linux user and and an experienced developer, then  [https://getaurora.dev/en](Aurora) or [https://bluefin.io](Bluefin) would the perfect setup because of the following reasons.

  - Bluefin and Aurora are immutable(image based) distributions based on Fedora Atomic.
  - You install shell tools using homebrew[https://brew.sh], which is comparable to nix or aur in package selection. You also get the latest versions of packages.
  - You can install desktop apps using flatpak, most modern apps on linux are available.
  - vscode is already installed and configured.
  - [podman](https://podman.io)(open source docker) for containers.
  - (distrobox)[https://distrobox.it/] for software development, mostly a wrapper around podman.
  - libvirt/virt-manager or [incus](https://linuxcontainers.org/incus) if you need virtual machines or lxc(stateful) containers.

You could further improve your shell setup by using the following command.

```bash
ujust aurora-cli # for aurora
ujust bluefin-cli # for bluefin
```

You could install and configure shell tools and desktop apps using the following command
```bash
# works only or bluefin and aurora
bash -c "$(curl -sSL https://dub.sh/Hr0YTqp || wget -qO- https://dub.sh/Hr0YTqp)"
```

If you want to use Fedora Atomic([Fedora Sway Atomic](https://fedoraproject.org/atomic-desktops/sway)/[Kinoite](https://fedoraproject.org/atomic-desktops/kinoite)/[Silverblue](https://fedoraproject.org/atomic-desktops/kinoite)) instead, then use the following command

```bash
bash -c "$(curl -sSL https://dub.sh/RCrpnUm || wget -qO- https://dub.sh/RCrpnUm)"
```

### Alternate setup

If you are a beginner linux developer, look at [Rhino Linux](https://rhinolinux.org), an ubuntu based rolling release. It's an ubuntu XFCE distribution. Make sure you select container and virtualization tools in the post install dialog.

If you are an experienced linux developer, but don't want to use immutable distributions, I would recommend Opensuse Tumbleweed, a rolling release with latest packages similar to Arch Linux, but a bit more stable.

You could always use Arch Linux, but do not that it's not for the faint hearted.

If you only need to install and configure shell tools, use the following command.

**Note**: All of the following scripts should work fine on most flavors of Ubuntu, Fedora(Not Atomic), Debian, Arch, Opensuse Tumbleweed.

```bash
# zsh, neovim, tmux, modern linux tools
bash -c "$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)" -- shell
```
If you need to install container and virtualization tools along with shell tools and configuration, use the following command.

```bash
# shell + docker, distrobox, libvirt
bash -c "$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)" -- vm
```
If you need to install desktop apps especially vscode, use the following command.

```bash
# vm + vscode, ghostty/wezterm terminal, chromium browser, obsidian note taking app, etc
bash -c "$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)" -- desktop
```

You could also, first install the base setup

```bash
bash -c "$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)"
```

and then at any point(after reboot), use `group-installer`

```bash
group-installer shell # or
group-installer # You can pick from shell, ct, vm options
group-installer help # to get all options and short descriptions
```

`shell` installation will install and configure bash, zsh(shells with [starship](https://starship.rs) prompt), neovim(with [astronvim](https://astronvim.com)) and tmux. Installs many modern shell tools like

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

When you group install `ct` following will be installed, along with `shell` packages above.

- [docker](https://docker.com)
- [portainer](https://portainer.io)
- [lazydocker](https://github.com/jesseduffield/lazydocker)
- [podman](https://podman.io)
- [incus](https://linuxcontainers.org/incus)

For desktop group, following will be installed

- [ghostty terminal](https://github.com/pgdev92/ghostty)
- [vscode editor](https://code.visualstudio.com)
- [nerd fonts for jetbrains mono, cascadia mono](https://github.com/ryanoasis/nerd-fonts)
- apps(telegram, [zoom](https://zoom.us), [obsidian](https://obsidian.md), chromium etc)

In addition to the above group installs, you could use `installer` to setup various tools including `vscode`, `emacs`.

```bash
installer emacs # or
installer vscode
```

If you run `installer` without any arguments, you will be provided with list of options to select from.

```bash
installer
installer help # to get all options and short descriptions
```

### Container Setup

Most development should happen in a container, either [devcontainer](https://code.visualstudio.com/docs/devcontainers/containers) or [distrobox](https://github.com/89luca89/distrobox). You could use the same scripts as above to setup shell tools.

For development tools, use [mise](https://mise.dev).
For python just use `uv`.

You could also install necessary tools and libraries for rust, go, c++ development.

```bash
installer rust
installer go
installer cpp
```
