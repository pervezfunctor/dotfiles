# development environment setup

## MacOS

Run the following command to set up the macOS development environment:

```bash
zsh -c "$(curl -sSL https://raw.githubusercontent.com/pervezfunctor/dotfiles/master/installers/macos/desktop)"
```

_Important Note_: Make sure you use nerd font in your terminal. Above installs `jetbrains mono` and `monaspace` fonts.

## GCP Rocky Linux

To set up a shell environment in your Google Compute Rocky Virtual Machine, run the following command:

```bash
zsh -c "$(curl -sSL https://dub.sh/BP7nenx)"
```

Assumes, that necessary packages are already installed in the virtual machine. If not installed, run the following command:

```bash
zsh -c "$(curl -sSL https://dub.sh/U6eEivg)"
```

## Windows

In Windows, install [Rocky Linux](https://download.rockylinux.org/pub/rocky/9/isos/x86_64/Rocky-9.3-x86_64-minimal.iso) in a `hyper-v` virtual machine. Run the following command in the virtual machine.

```bash
bash -c "$(curl -sSL https://dub.sh/zEIpneC)"
```

_Important Note_: Make sure you use nerd font in the [Windows terminal](https://apps.microsoft.com/detail/9N0DX20HK701?hl=en-US&gl=US). Do not use `putty` or `command prompt`.

## Fedora

In Fedora 39, run the following command:

```bash
bash -c "$(curl -sSL https://dub.sh/zEIpneC)"
```

_Important Note_: Make sure you use nerd font in your terminal. Use a terminal like [alacritty](https://alacritty.org/index.html), `kitty`, `wezterm`, `konsole` or anything that supports true 32-bit color.

Preferably install `Rocky Linux` in a virtual machine using `virt-manager` and use it as a development environment.
Within the virtual machine, run the following command:

```bash
bash -c "$(curl -sSL https://dub.sh/zEIpneC)"
```
