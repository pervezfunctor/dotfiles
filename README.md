# Ilm development environment

### Installation on Fedora/Rocky

```bash
bash -c "$(curl -sSL https://dub.sh/zEIpneC)"
```

### Minimal installation on Ubuntu/Debian

```bash
bash -c "$(wget -qO- https://dub.sh/aPKPT8V)"
```

### Zsh environment

```bash
mv ~/.zshrc ~/.zshrc.bak
curl -sSL https://dub.sh/YY3a8Um > ~/.zshrc
```

### Tmux environment

```bash
mv $XDG_CONFIG_HOME/tmux.conf $XDG_CONFIG_HOME/tmux.conf.bak
curl -sSL https://dub.sh/me3OYAJ > $XDG_CONFIG_HOME/tmux.conf
```

### Installer

Once you run one of the above scripts, you could then select what you want to install from the following options.

Following editors are supported

- neovim
- vscode
- emacs

Following languages are supported

- python(pyenv and miniconda)
- pnpm(web development)
- cpp(cmake, boost, gcc, clang)
- rust
- go

Following virtualization tools are supported

- docker
- podman
- incus
- libvirt
- cockpit
- ct(docker, podman, incus)
- virt(ct and libvirt)

If you want a good shell configuration, following options are supported

- config (this will configure zsh, tmux, and git, but without installing any packages)
- shell (installs all shell tools but without any config)

On your desktop, following options are supported

- alacritty
- fonts
- apps(telegram, zoom, chromium etc)

For example if you need web and zsh environment, you would run

```bash
bash -c "$(wget -qO- https://dub.sh/kceoClT)" -- web config
```

If I only need configuration without any packages(for eg: On arch linux, install any of zsh, git, tmux, neovim, emacs)

```bash
bash -c "$(wget -qO- https://dub.sh/kceoClT)" -- config
```

## Full Installations(Not recommended).

IF you are on a desktop, you could install everything in go using the following commands.

### MacOS

```bash
zsh -c "$(curl -sSL https://dub.sh/I2dJKhb)"
```

### Rocky Linux

```bash
bash -c "$(curl -sSL https://dub.sh/WFQOW36)"
```

### Fedora

```bash
bash -c "$(curl -sSL https://dub.sh/OKPDJA4)"
```

### Ubuntu

```bash
bash -c "$(wget -qO- https://dub.sh/NAWwPIu)"
```

### Debian

```bash

bash -c "$(wget -qO- https://dub.sh/6a0zdj1)"
```
