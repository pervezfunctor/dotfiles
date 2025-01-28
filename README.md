# Ilm development environment

### Base installation on Ubuntu/Fedora/Debian/Rocky/Macos/Arch/Tumbleweed

```bash
bash -c "$(curl -sSL https://dub.sh/aPKPT8V)"
bash -c "$(curl -sSL https://dub.sh/aPKPT8V)" -- shell # zsh, neovim, tmux, modern linux tools
bash -c "$(curl -sSL https://dub.sh/aPKPT8V)" -- vm    # shell + docker, distrobox, libvirt
bash -c "$(curl -sSL https://dub.sh/aPKPT8V)" -- desktop # vm + vscode, ghostty/alacritty, chromium, obsidian etc
```

Reboot your machine and use `group-installer` command to setup your shell or workstation in virtual machine or your desktop.

```bash
group-installer shell # or
group-installer # You can pick from shell, ct, vm options
group-installer help # to get all options and short descriptions
```

`shell` installation will install and configure bash, zsh(shells with starship prompt), neovim(with astronvim) and tmux. Installs many modern shell tools like

- fzf
- zoxide
- fd
- just
- gh(github cli)
- eza

When you group install `ct` following will be installed, along with `shell` packages above.

- docker
- podman
- incus
- portainer
- lazydocker

```bash
group-installer ct
```
You could also install libvirt etc with group `vm` which includes `ct` packages

For desktop group, following will be installed

- ghostty terminal
- vscode editor
- nerd fonts for jetbrains mono, cascadia mono
- apps(telegram, zoom, obsidian, chromium etc)

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

You could also install necessary tools and libraries for the following languages.
Following languages are supported. **Note**: For python just use `uv`.

```bash
installer rust go cpp web
```
