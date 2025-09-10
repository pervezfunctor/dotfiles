# Development environment

## Installation on your current system

All the following commands are meant to be run on a freshly installed system. If you run it on an existing system, you will lose some of your configuration.

## TLDR

<details>

<summary>MacOS</summary>

  ### MacOS

  Installs vscode, docker and shell tools.

  ```bash
  curl https://pkgx.sh | sh
  pkgx bash -c "$(curl -sSL https://is.gd/egitif)" -- work
  ```
</details>

<details>
<summary>Linux</summary>

  ### Linux

  Installs vscode, docker and shell tools.

  ```bash
  bash -c "$(curl -sSL https://is.gd/egitif || wget -qO- https://is.gd/egitif)" -- work
  ```
</details>

<details>
<summary>Windows</summary>

  ### Windows

  Pick what you want to install by running the following command in powershell as **administrator**. Note that you might have to restart your system multiple times. Execute the same script again after reboot.

  ```powershell
  iwr -useb https://is.gd/vefawu | iex
  ```
</details>


## Introduction

<details>
<summary>Linux></summary>

### Linux

Install essential packages(gcc, make, tar, git etc)

```bash
bash -c "$(curl -sSL https://is.gd/egitif || wget -qO- https://is.gd/egitif)"
```

Restart your terminal and use `ilmg` to install additional tools you want.

```bash
ilmg
```

You could also do the following

```bash
ilmg vscode docker shell vm # pick any tools you want
```

Optionally, install `nix`.

```bash
ilmi nix
```

</details>

<details>
<summary>Windows</summary>

### Windows

Install all Windows updates, if you haven't already.

On windows, use WSL.

```powershell
wsl --install --no-distribution
```

List of official WSL distributions are available.

```powershell
wsl --list --online
```

Install any of them. For example, to install fedora.

```powershell
wsl --install FedoraLinux-42
wsl --set-default FedoraLinux-42
wsl -d FedoraLinux-42
```

Setup `wsl` with the following command.

```bash
bash -c "$(curl -sSL https://is.gd/egitif || wget -qO- https://is.gd/egitif)" -- wslbox
```

Exit and enter WSL again to install more development tools.

```bash
ilmi tmux nvim emacs # pick any tools you want
```

Optionally, Execute the following and pick what you want. Do not uncheck any of the default options.

```powershell
iwr -useb https://is.gd/vefawu | iex
```

If this is blocked by your firewall, try

```powershell
iwr -useb https://raw.githubusercontent.com/pervezfunctor/dotfiles/refs/heads/main/windows/windows-setup-dev.ps1 | iex
```

Consider using [nixos-wsl](https://github.com/nix-community/nixos-wsl). You could install nixos-wsl with the above command.

Following might work too.

```powershell
& ([scriptblock]::Create((iwr -useb https://dub.sh/NDyiu7a).Content)) -Components wsl-nixos
```

</details>

<details>
<summary>MacOS</summary>

### MACOS


Install homebrew and a few essentials with the following command.

```bash
bash -c "$(curl -sSL https://is.gd/egitif)"
```

Restart terminal and use `ilmg` to install additional tools.

```bash
ilmg
```

Or

```bash
ilmg vscode docker
```

Simple tools could be installed with `ilmi`.

```bash
ilmi tmux nvim
```


</details>


## Popular Linux Distributions


### Ubuntu

Use [Omakub](https://omakub.org/) if you are using Ubuntu LTS.


### Arch Linux

Use [Omarchy](https://omarchy.org/) if you want to use Arch Linux for development.

You could still use some tools from this repository on both `omarchy` and `omakub`.

```bash
git clone https://github.com/pervezfunctor/dotfiles.git ~/.ilm
```

Add the following to your `~/.bashrc` and/or `~/.zshrc`.

```bash
source ~/.ilm/share/shellrc
```


## Recommended Linux Distributions

<details>
<summary>Bluefin/Aurora</summary>

### Bluefin/Aurora

Give [Bluefin](https://projectbluefin.io)/[Aurora](https://getaurora.dev/en)/[Bazzite](https://bazzite.gg/) a try. Especially if you have an nvidia card.

Unfortunately, there is no direct ISO of dx version available. You need to run the following command after installation.

```bash
ujust devmode
```

You could instead create your own custom ublue distribution using [ublue template](https://github.com/ublue-os/image-template). if you have an nvidia card, you could instead use my [custom image](https://github.com/pervezfunctor/ilm-os). Currently I add virt-install. I intend to keep this simple. You could switch to my image with the following command(preferrably from Bazzite, Aurora or Kinoite).

```bash
sudo bootc switch ghcr.io/pervezfunctor/ilm-os:latest
```

Once you have your OS installed with any of the above approaches, you could configure vscode and shell with the following command.

```bash
bash -c "$(curl -sSL https://is.gd/egitif) -- ublue"
```

You could instead run the following.

```bash
ujust bluefin-cli  # for bluefin
ujsut aurora-cli   # for aurora
ujust bazzite-cli  # for bazzite
```

and then use the following in `~/.bashrc` and/or `~/.zshrc`.

```bash
source ~/.ilm/share/shellrc
```

</details>

<details>
<summary>NixOS</summary>

### Nixos

Install [nixos](https://channels.nixos.org/) using [graphical iso](https://channels.nixos.org/nixos-25.05/latest-nixos-graphical-x86_64-linux.iso).

Execute the following script only on a freshly installed system.

```bash
bash -c "$(curl -sSL https://is.gd/egitif)" -- nixos
```

Your nixos configuration will be stored in `~/.ilm/extras/nixos/config`. Add to git and push to github.

You should be able to use the following command to update your system after you make changes to your configuration.

```bash
sudo nixos-rebuild switch --flake ~/nixos-config#$(hostname)
```

</details>

<details>
<summary>Fedora Atomic</summary>

### Fedora Atomic(Silverblue, Kinoite, Sway Atomic)

If you don't want to use rpm-ostree, then use distrobox for everything instead. I have multiple distrobox containers for different purposes. But they are brittle. Not everything works perfectly. Anyway, you could use the following command for such a setup.

```bash
bash -c "$(curl -sSL https://is.gd/egitif)" -- fedora-atomic
```

Above command should install some basic tools on the host, but developer tools(`vscode`, `docker` etc.) are inside a distrobox container.

I will add more instructions to use distrobox and toolbox in the future. For now, you could use the following command to use `vscode` from distrobox container.

```bash
dboxe ilm # enter distrobox container
code # opens vscode from distrobox container
```

</details>


## Conventional Linux

If you are a developer, I would highly recommend using linux on your personal desktop. There are interesting things in happening in this space. As a developer you will have a lot of fun.

If you don't have a personal desktop, just buy a mini pc. You could get a decent minipc for [$300-$400](https://www.amazon.com/AOOSTAR-GEM10-7840HS-Computer-OCULINK/dp/B0F2DW9HFC). Even a nuc could cost around [500$](https://www.amazon.com/ASUS-Barebones-ThunderboltTM-Bluetooth-Toolless/dp/B0F1BBSF76). You could use it as a desktop, development machine or a server.

If you are fine with a server that's capable of running docker, you could buy N100/N150 mini pc, which should be around [150$](https://www.amazon.com/GMKtec-mini-pc-desktop-computer-n150/dp/B0DN51KD9D). You would be surprised how much such a cheap machine can do.


<details>
<summary>Fedora Workstation</summary>

### Fedora Workstation(42 only)

Fedora Workstation/Fedora KDE/Fedora Sway are all good choices. They are stable, have the latest kernel supporting most modern hardware. Most software is latest or will be in fedora soon. This has the right balance of stability and latest software. This is also the operating system, where majority of the interesting things are happening in the linux desktop space.

Download fedora workstation from [here](https://getfedora.org/en/workstation/download/) and install it on a separate disk. DO NOT use dual boot.

Once installation is done(which is pretty fast and easy), on first boot, make sure you enable third party repositories. This will allow you to install nvidia drivers and proprietary codecs. If you forgot to enable third party repositories, you could do so later [manually](https://rpmfusion.org/Configuration).

Once nvidia drivers and codecs are installed, update your system. Use the following command.

```bash
sudo dnf update -y
```

Reboot your system.
</details>

<details>
<summary>Debian Trixie</summary>

### Debian Trixie

Debian Trixie is as stable as linux gets. You must have used debian/ubuntu for your docker containers, at least for development. If you are familiar with the debian ecosystem, Debian Trixie, will be very familiar to you.  Comes with a fairly recent kernel, and supports most modern hardware.

Use Live CD iso as it uses Calamares installer. Use btrfs filesystem. netinstall won't be a great experience. If you want to use this in a virtual machine, I would recommend KDE.

Make sure you update your system after installation and curl is installed. Use the following command.

```bash
sudo apt update && sudo apt upgrade -y && sudo apt install curl -y
```

Reboot your system.

</details>

<details>
<summary>OpenSUSE Tumbleweed</summary>

### OpenSUSE Tumbleweed

OpenSUSE Tumbleweed is a rolling release distribution. It has the latest kernel and supports almost all hardware that linux supports. Even though it has the latest software, it's very stable, more stable than Fedora. Tumbleweed also has more packages available than any other convention linux os(like arch without AUR).

Tumbleweed has one serious issue though. It's installer is fragile. It's nowhere near as good as or as polished as Fedora or Ubuntu installer. Once installed, it works great though. You could use the [openSUSE Tumbleweed installer](https://en.opensuse.org/Portal:Tumbleweed/Installation) to install it.

Make sure you install the latest kernel and update your system after installation. Use the following command.

```bash
sudo zypper refresh && sudo zypper update -y
```

Reboot your system.

</details>

<details>
<summary>Arch Linux</summary>

### Arch Linux

This is another rolling release distribution. This is the least stable operating system, especially if you use AUR.

If you want to learn how linux works and different moving parts in a linux desktop, you MUST install archlinux manually following the [Arch Wiki](https://wiki.archlinux.org/title/Installation_guide); at least once. You will learn a lot about linux, how it works, how to configure it, and how to troubleshoot issues. `Arch Wiki` is an amazing resource.

You could later either use [archinstall](https://archinstall.readthedocs.io/en/latest/) or use a distriution like [CachyOS](https://cachyos.org/download/) to install arch linux.


Once you have installed archlinux using any of the approaches above, make sure you update your system. Use the following command.

```bash
sudo pacman -Syu --noconfirm
```

Reboot your system.

*Note*. If you are comfortable with terminal, and know what you need exactly, then archlinux is the simplest installer you could use for linux. With almost everything else, you will need to figure out ways, how to install and configure things the way you want and it's usually can be really hard.

</details>

### Common instructions

For all of the above operating systems, you could *follow the same instructions* below.


Install modern shell tools with the following command.

```bash
bash -c "$(curl -sSL https://is.gd/egitif)" -- shell-slim
```

This command should setup your zsh, tmux and install tools like `ripgrep`, `eza`, `fzf`, `zoxide`, `bat`, `git-delta` etc.

Sometimes setting your shell to zsh during installation, might not work. In that case, you could use the following command.

```bash
chsh -s $(which zsh)
```

Reopen your terminal and you should see a nice zsh prompt. You must install a nerd font like `Jetbrains Mono Nerd Font`.

As a developer you most probably need vscode. Install it with the following command.

```bash
ilmg vscode
```

This will install `vscode`. It should also install some essential extensions. Open `vscode` and you should see a nice theme with jetbrains mono font.

If you need docker, I would highly recommend you install it in a virtual machine. If you prefer to install it on your host OS, you could use the following command.

```bash
ilmg docker
```

Note that `podman` and `docker` don't work well together. `podman` is installed by default in Fedora.

You should be able to use `vscode` and `devcontainers` without any issues. *You must reboot after installing docker*.

I would highly recommend you install `libvirt` and `virt-manager` for creating and managing virtual machines. You could use the following command.

```bash
ilmg vm
```

*Once you reboot*, you should be able to create and use virtual machines.

I have a few helper scripts to make creating headless virtual machines easier.

First generate ssh key, if you don't have it already.

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

Then create a vm with the following command. This will create a debian vm with docker and ssh enabled.

```bash
vm-create --distro debian --name dev --docker
```

After a few minutes, you should be able to ssh into this vm with the following command. If you don't have ssh key set up, this script will generate one for you. Use the username `debian` and password `debian`.

```bash
vm ssh dev debian # debian is the user name
```

You could also use the following command for console access to vm.

```bash
vm console dev
```

If you are not using Fedora, you need a better terminal. You could easily install `ptyxis` with the following command.

```bash
ilmi ptyxis
```

Remember to pick `Jetbrains Mono Nerd Font` as the font. Pick a nice theme like `Catppuccin Mocha`, `Tokyo Night` or `Everforest`.

`ptyxis` is a great terminal, and works well with `distrobox`. You could use it as your main terminal. You could install distrobox with

```bash
ilmi distrobox
```

## Generic Linux Desktop

This should work on almost any linux system/vm/container even without sudo privileges; You should have curl/wget and bash installed.


This will only install shell tools.

```bash
bash -c "$(curl -sSL https://is.gd/egitif || wget -qO- https://is.gd/egitif)" -- generic
```


## Linux Development Container/VM(mutable distributions only)

Install essential tools and bash config with

```bash
bash -c "$(curl -sSL https://is.gd/egitif || wget -qO- https://is.gd/egitif)" -- slimbox
```

You could later install additional development tools with

```bash
ilmb zsh tmux nvim emacs # pick any
```

If you are in a distrobox or in a virtual machine with desktop environment, you could install terminal with

```bash
ilmg terminal
```

You can install vscode with

```bash
ilmg vscode
```

I will try to provide similar commands for immutable/nixos distributions in the future.


## Proxmox

This is an amazing hypervisor for almost anything. It's really simple to use, even if you don't know linux much. Just buy a minipc worth 150$ and install proxmox on it. You could learn a lot about linux, devops and cloud computing. I setup kubernetes clusters, docker/podman/lxc comtainers in multiple virtual machines without any problem. You could use Ceph if you need distributed storage for your cluster. Install desktop linux or windows if you need to. Passthrough your gpu to windows or bazzite and play games at close to bare metal fps.

Basic setup can be done with the following command.

```bash
bash -c "$(curl -sSL https://is.gd/epesoq)"
```
