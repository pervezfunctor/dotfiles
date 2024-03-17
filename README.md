# Ilm development environment

### MacOS

```bash
zsh -c "$(curl -sSL https://dub.sh/I2dJKhb)"
```

### Rocky Linux

```bash
bash -c "$(curl -sSL https://dub.sh/WFQOW36)"
```

### Kinoite/Silverblue

First, install the necessary tools you want using `rpm-ostree` and reboot. For eg:

```bash
sudo rpm-ostree install -y zsh tmux tar trash-cli micro noevim
```

Then run the following script

```bash
bash -c "$(curl -sSL https://raw.githubusercontent.com/pervezfunctor/dotfiles/main/installers/kinoite)"
```

Reboot again. You might have to run the following command.

```bash
sudo systemctl enable --now libvirtd
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

### Minimal installation on Fedora/Rocky

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
mv ~/.config/tmux.conf ~/.config/tmux.conf.bak
curl -sSL https://dub.sh/me3OYAJ > ~/.config/tmux.conf
```

### Installer

You could select what you want to install from the following options.

Following editors are supported

- neovim
- vscode
- emacs

Following languages are supported

- python(pyen, poetry and miniconda)
- pnpm(web development)
- cpp(c++ development)
- rust
- go

Following virtualization tools are supported

- docker
- podman
- libvirt
- cockpit
- ct(docker, podman)
- virt(ct and libvirt)

If you want a good shell configuration, following options are supported

- config (this will configure zsh, tmux, and git, but without installing any packages)
- shell (installs all shell tools but without any config)

On your desktop, following options are supported

- alacritty
- fonts
- apps(telegram, zoom, chromium etc)

For example if I need web and zsh environment, I would run

```bash
bash -c "$(wget -qO- https://dub.sh/kceoClT)" -- web config
```

If I only need configuration without any packages(for eg: On arch linux, install any of zsh, git, tmux, neovim, emacs)

```bash
bash -c "$(wget -qO- https://dub.sh/kceoClT)" -- config
```
