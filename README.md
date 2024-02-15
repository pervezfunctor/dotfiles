# Ilm development environment

## MacOS

```bash
zsh -c "$(curl -sSL https://raw.githubusercontent.com/pervezfunctor/dotfiles/master/installers/macos/desktop)"
```

## Rocky Linux

```bash
bash -c "$(curl -sSL https://raw.githubusercontent.com/pervezfunctor/dotfiles/master/installers/dnf/rocky)"
```

## Fedora

```bash
bash -c "$(curl -sSL https://raw.githubusercontent.com/pervezfunctor/dotfiles/master/installers/dnf/fedora)"
```

## Ubuntu

```bash
sudo apt install -y curl
bash -c "$(curl -sSL https://raw.githubusercontent.com/pervezfunctor/dotfiles/master/installers/apt/ubuntu)"
```

## Debian

```bash
sudo apt install -y curl
bash -c "$(curl -sSL https://raw.githubusercontent.com/pervezfunctor/dotfiles/master/installers/apt/debian)"
```

## Minimal installation on Fedora/Rocky

```bash
bash -c "$(curl -sSL https://raw.githubusercontent.com/pervezfunctor/dotfiles/master/installers/dnf/min)"
```

## Minimal installation on Ubuntu/Debian

```bash
sudo apt install -y curl
bash -c "$(curl -sSL https://raw.githubusercontent.com/pervezfunctor/dotfiles/master/installers/apt/min)"
```

## Zsh environment

```bash
mv ~/.zshrc ~/.zshrc.bak
curl -sSL https://raw.githubusercontent.com/pervezfunctor/dotfiles/master/configs/zshrc > ~/.zshrc
```

## Tmux environment

```bash
mv ~/.config/tmux.conf ~/.config/tmux.conf.bak
curl -sSL https://raw.githubusercontent.com/pervezfunctor/dotfiles/master/configs/tmux.conf > ~/.config/tmux.conf
```
