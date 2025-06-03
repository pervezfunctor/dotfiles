## Alternate setup

**Note**: All of the following scripts should work fine on most flavors of `Ubuntu`, `Fedora`(except Atomic), `Debian`, `Rocky`, `Arch` and `Opensuse Tumbleweed`.

If you are a beginner linux developer, use Fedora Workstation, it's awesome! If you need Ubuntu, take a look at [Rhino Linux](https://rhinolinux.org). Make sure you select container and virtualization tools in the post install dialog. Rhinos uses xfce, perfect for low end laptops.

If you are an experienced linux developer, but don't want to use immutable distributions, I would recommend Opensuse Tumbleweed, a rolling release distribution similar to Arch Linux, but simpler and a bit more stable.

Install and configure shell tools with the following command.

```bash
bash -c "$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)" -- shell
```

Install container and virtualization tools(in addition to above shell tools and configuration), with following command.

```bash
bash -c "$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)" -- vm
```

Install desktop apps including vscode(in addition to above), with the following command.

```bash
bash -c "$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)" -- desktop
```

You could also, first install the base setup

```bash
bash -c "$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)"
```

and then at any point(after reboot), use `ilmg`.

```bash
ilmg
ilmg help
```

You could pick from `shell`, `ct`, `vm`, `desktop` and `dev` groups.

`shell` will install and configure zsh and bash(with [starship](https://starship.rs) prompt), neovim(with lazyvim](http://www.lazyvim.org)) and [tmux](https://github.com/tmux/tmux/wiki). Installs modern shell tools like

- [gh - github cli](https://cli.github.com)
- [just - task runner](https://github.com/casey/just)
- [fzf - fuzzy finder](https://github.com/junegunn/fzf)
- [zoxide - smart cd](https://github.com/ajeetdsouza/zoxide)
- [fd - find](https://github.com/sharkdp/fd)
- [eza - modern ls](https://github.com/eza-community/eza)
- [bat - modern cat](https://github.com/sharkdp/bat)
- [delta - git diff](https://github.com/dandavison/delta)

Following optional utilities might also be installed

- [lazygit - git ui](https://github.com/jesseduffield/lazygit)
- [procs - modern ps](https://github.com/dalance/procs)
- [sd - modern sed](https://github.com/chmln/sd)
- [xh - modern httpie](https://github.com/ducaale/xh)
- [bottom - modern top](https://github.com/ClementTsang/bottom)
- [duf - modern df](https://github.com/muesli/duf)
- [cheat - cheat sheet](https://github.com/cheat/cheat)

`ct` will install the following, along with `shell` packages above.

- [podman](https://podman.io)
- [incus](https://linuxcontainers.org/incus)
- [docker](https://docker.com)
- [portainer](https://portainer.io)
- [lazydocker](https://github.com/jesseduffield/lazydocker)

`desktop` will install the following, along with `shell` packages above.

- [Ptyxis terminal](https://gitlab.gnome.org/chergert/ptyxis) or [ghostty terminal](https://github.com/pgdev92/ghostty)
- [vscode editor](https://code.visualstudio.com)
- [jetbrains mono nerd font](https://github.com/ryanoasis/nerd-fonts)
- apps(like [zoom](https://zoom.us), [obsidian](https://obsidian.md), chromium etc)

In addition to the above group installs, you could also use `installer` to setup various tools like `emacs`.

```bash
ilmi
```

Pass `help` to get all options and short descriptions, run

```bash
ilmi help
```
