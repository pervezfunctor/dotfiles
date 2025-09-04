# Development environment

## Installation on your current system

All the following commands are meant to be run on a freshly installed system. If you run it on an existing system, you will lose some of your configuration.

## TLDR

### MacOS

Installs vscode, docker and shell tools.

```bash
curl https://pkgx.sh | sh
pkgx bash -c "$(curl -sSL https://is.gd/egitif)" -- work
```

### Linux

Installs vscode, docker and shell tools.

```bash
bash -c "$(curl -sSL https://is.gd/egitif || wget -qO- https://is.gd/egitif)" -- work
```


### Windows

Pick what you want to install by running the following command in powershell **as administrator**. Note that you might have to restart your system multiple times. Execute the same script again.

```powershell
iwr -useb https://is.gd/vefawu | iex
```

## Introduction

### Linux

If you only want to install modern unix tools in a development container/vm/desktop, use the following command instead. Works on linux and macos.

```bash
bash -c "$(curl -sSL https://is.gd/egitif || wget -qO- https://is.gd/egitif)" -- shell-slim
```

Or just install the very basic packages(gcc, make, tar, git etc)

```bash
bash -c "$(curl -sSL https://is.gd/egitif || wget -qO- https://is.gd/egitif)"
```

Restart your terminal and use `ilmi` to install additional tools you want.

```bash
ilmi
```

You could also do the following
```bash
ilmi vscode docker shell-ui vm-ui # pick any tools you want
```

Consider using `nix` and [home-manager](https://github.com/nix-community/home-manager).

Use the following to install `nix`.

```bash
ilmi nix
```

Setup home-manager with the following.

```bash
cp ~/.ilm/home-manager/dot-config/home-manager ~/.config/home-manager
cd ~/.config/home-manager
git init
git add .
./hms
git add .
git commit -m "Initial commit"
chsh -s $(which zsh)
```


### Windows

On windows, use WSL. Install WSL, use the following command.

```powershell
wsl --install --no-distribution
```

I recommend fedora for development. You could also use Ubuntu 25.04.

```powershell
wsl --list --online # Pick any from here in the following command.
wsl --install FedoraLinux-42
wsl -d FedoraLinux-42 # Create user and set a password.
```

Run the following command in WSL for installing basic tools and a nice shell prompt. Make sure you are not root.

```bash
bash -c "$(curl -sSL https://is.gd/egitif || wget -qO- https://is.gd/egitif)" -- wslbox
```

Exit and enter WSL again(or reboot) to install more development tools.

```bash
ilmi tmux nvim emacs # pick any tools you want
```

If you want to setup vscode and other development tools on Windows, run the following command in powershell **as administrator**.

Install Windows updates first, if you haven't already.

Then you could install `vscode` with

```powershell
iex "& { $(iwr -useb https://is.gd/vefawu) -Components vscode nerd-fonts }"
```

Install [docker desktop](https://docs.docker.com/desktop/setup/install/windows-install/) manually or use the following

```powershell
iex "& { $(iwr -useb https://is.gd/vefawu) -Components devtools }"
```

Or execute the following and pick what you want. Do not uncheck any of the default options.

```powershell
iwr -useb https://is.gd/vefawu | iex
```

Consider using [nixos-wsl](https://github.com/nix-community/nixos-wsl).

You could install nixos-wsl with the following command.

```powershell
iex "& { $(iwr -useb https://is.gd/vefawu) -Components wsl-nixos }"
```

### MACOS


Install homebrew and a few essentials with the following command.

```bash
bash -c "$(curl -sSL https://is.gd/egitif)"
```

You could later use `ilmi` to install additional tools

```bash
ilmi vscode docker tmux nvim # pick any tools you want
```

Consider using [nix-darwin](https://github.com/nix-darwin/nix-darwin) or at least [home-manager](https://github.com/nix-community/home-manager)


## Recommended Setups


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
bash -c "$(curl -sSL https://is.gd/hurace)"
```

You could instead run the following.

```bash
ujust bluefin-cli  # for bluefin
ujsut aurora-cli   # for aurora
ujust bazzite-cli  # for bazzite
```


### Nixos

Install [nixos](https://channels.nixos.org/) using [graphical iso](https://channels.nixos.org/nixos-25.05/latest-nixos-graphical-x86_64-linux.iso).

Once installed copy configuration to your home folder.

```bash
mkdir -p ~/nixos-config
cp -r /etc/nixos ~/nixos-config
```

Edit `~/nixos-config/configuration.nix` and add the following.

```nix
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

Create a minimal flake.nix.

```bash
cat > ~/nixos-config/flake.nix << EOF
{
  description = "NixOS flake configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      nixosConfigurations = {
        "$(hostname)" = pkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./configuration.nix
          ];
        };
      };
    };
EOF
```

Initialize git repository and stage all files.

```bash
git init ~/nixos-config
git add configuration.nix flake.nix hardware-configuration.nix
```

Run the following command to apply configuration.

```bash
nixos-rebuild switch --flake ~/nixos-config#$(hostname)
git add flake.lock
git commit --amend --no-edit
```

This should do almost nothing. Now you could edit `configuration.nix` and add any additional packages you want.

Don't forget to push your configuration to github.

Look at `~/.ilm/extras/nixos/config` for my configuration.


### Fedora Atomic(Silverblue, Kinoite, Sway Atomic)

Fedora Atomic is great and the future of fedora if not linux in general. Unfortunately, atomic comes with almost nothing for developers and you have to use distrobox/toolbox for everything. This can be a frustrating experience. This will be a more stable operating system in practice than other approaches(conventional or ublue based).

### rpm-ostree based Setup

I would recommend you don't spend too much time configuring everything in a distrobox and spend multiple frustrating hours trying to get everything to work. Distrobox approach is still a work in progress, and hopefully in near future, this option will be simple. Until then, use `rpm-ostree` instead, as it's really easy to get it to work. Note that using rpm-ostree too many times is a bad idea. Refer to Fedora Atomic documentation about the best practices.

Install essential development tools like `vscode`, and `virt-manager` with the following command.

```bash
bash -c "$(curl -sSL https://is.gd/egitif)" -- rpm-ostree
```

After Installation, reboot(necessary) and execute the following command.

```bash
ilmi rpm-ostree-post
```

Reboot Again. And this is necessary. Check if vscode, virt-install are installed.

If you need docker, you should install it in a vm, and use `vscode` to ssh into this virtual machine. `devcontainers` work really well using this approach.

Generate ssh key, if you don't have it already.

```bash
ssh-keygen -t ed25519 -C "<your_email@example.com>"
```

Then create a vm with the following command. This will create a debian vm with docker, brew and dotfiles.

```bash
vm-create --distro debian --name dev --docker --brew --dotfiles --username debian --password debian min
```

You should not install anything on the host. You could use `distrobox` for command line tools. Use flatpak for desktop applications. Use `devcontainers` for development from `vscode`(or `jetbrains` or `neovim`). You could use `virt-install/virsh/virt-viewer` or `virt-manager` to create and manage virtual machines.

**Note**: If your virtual machines do not get an IP address, edit `/etc/libvirt/network.conf` and add the following.

```
firewall_backend = "iptables"
```

and restart libvirtd service.

```bash
sudo systemctl restart libvirtd
```

###  Atomic Setup

IF you don't want to use rpm-ostree, then use distrobox for everything instead. I have multiple distrobox containers for different purposes. But they are brittle. Not everything works perfectly. Anyway, you could use the following command for such a setup.

```bash
bash -c "$(curl -sSL https://is.gd/egitif)" -- fedora-atomic
```

Above command should install some basic tools on the host, but developer tools(`vscode`, `docker` etc.) are inside a distrobox container.

I will add more instructions to use distrobox and toolbox in the future. For now, you could use the following commands to install some essential tools.

```bash
dboxe ilm # enter distrobox container
code # opens vscode from distrobox container
```


## Conventional Linux

If you are a developer, I would highly recommend using linux on your personal desktop. There are interesting things in happening in this space. As a developer you will have a lot of fun.

If you don't have a personal desktop, just buy a mini pc. You could get a decent minipc for [$300-$400](https://www.amazon.com/AOOSTAR-GEM10-7840HS-Computer-OCULINK/dp/B0F2DW9HFC). Even a nuc could cost around [500$](https://www.amazon.com/ASUS-Barebones-ThunderboltTM-Bluetooth-Toolless/dp/B0F1BBSF76). You could use it as a desktop, development machine or a server.

If you are fine with a server that's capable of running docker, you could buy N100/N150 mini pc, which should be around [150$](https://www.amazon.com/ASUS-Barebones-ThunderboltTM-Bluetooth-Toolless/dp/B0F1BBSF76). You would be surprised how much such a cheap machine can do.

I have stopped using Windows for anything. I hardly use macos. I use linux on almost all my machines, servers, homelab or personal desktop. Almost all of them are reasonably stable and support everything I need.


### Fedora Workstation(42 only)

Fedora Workstation/Fedora KDE/Fedora Sway are all good choices. They are stable, have the latest kernel supporting most modern hardware. Most software is latest or will be in fedora soon. This has the right balance of stability and latest software. This is also the operating system, where majority of the interesting things are happening in the linux desktop space.

Download fedora workstation from [here](https://getfedora.org/en/workstation/download/) and install it on a separate disk. DO NOT use dual boot.

Once installation is done(which is pretty fast and easy), on first boot, make sure you enable third party repositories. This will allow you to install nvidia drivers and proprietary codecs. If you forgot to enable third party repositories, you could do so later [manually](https://rpmfusion.org/Configuration).

Once nvidia drivers and codecs are installed, update your system. Use the following command.

```bash
sudo dnf update -y
```

Reboot your system.

### Debian Trixie

Debian Trixie is as stable as linux gets. You must have used debian/ubuntu for your docker containers, at least for development. If you are familiar with the debian ecosystem, Debian Trixie, will be very familiar to you.  Comes with a fairly recent kernel, and supports most modern hardware.

Use Live CD iso as it uses Calamares installer. Use btrfs filesystem. netinstall won't be a great experience. If you want to use this in a virtual machine, I would recommend KDE.

Make sure you update your system after installation and curl is installed. Use the following command.

```bash
sudo apt update && sudo apt upgrade -y && sudo apt install curl -y
```

Reboot your system.

### OpenSUSE Tumbleweed

OpenSUSE Tumbleweed is a rolling release distribution. It has the latest kernel and supports almost all hardware that linux supports. Even though it has the latest software, it's very stable, more stable than Fedora. Tumbleweed also has more packages available than any other convention linux os(like arch without AUR).

Tumbleweed has one serious issue though. It's installer is fragile. It's nowhere near as good as or as polished as Fedora or Ubuntu installer. Once installed, it works great though. You could use the [openSUSE Tumbleweed installer](https://en.opensuse.org/Portal:Tumbleweed/Installation) to install it.

Make sure you install the latest kernel and update your system after installation. Use the following command.

```bash
sudo zypper refresh && sudo zypper update -y
```

Reboot your system.

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


For all of the above operating systems, you could *follow the same instructions* below.


You could install modern shell tools with the following command.

```bash
bash -c "$(curl -sSL https://is.gd/egitif)" -- shell-slim
```

This command should setup your zsh, tmux and install tools like `ripgrep`, `eza`, `fzf`, `zoxide`, `bat`, `git-delta` etc.

Sometimes setting your shell to zsh during installation, might not work. In that case, you could use the following command.

```bash
chsh -s $(which zsh)
```

Reopen your terminal and you should see a nice zsh prompt. You must install a nerd font like `Jetbrains Mono Nerd Font`. You could install it with the following command.

```bash
ilmi fonts jetbrains-mono
```

As a developer you most probably need vscode. Install it with the following command.

```bash
ilmi vscode
```

This will install `vscode`. It should also install some essential extensions. Open `vscode` and you should see a nice theme with jetbrains mono font.


If you need docker, I would highly recommend you install it in a vm. If you prefer to install it on your host OS, you could use the following command.

```bash
ilmi docker
```

Note that `podman` and `docker` don't work well together. `podman` is installed by default in Fedora.

You should be able to use `vscode` and `devcontainers` without any issues. *You must reboot after installing docker*.

I would highly recommend you install `libvirt` and `virt-manager` for creating and managing virtual machines. You could use the following command.

```bash
ilmi vm-ui
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

If you are not using Fedora, you need a better terminal. You could easily install `ptyxis` with the following command.

```bash
ilmi flathub ptyxis
```

Remember to pick `Jetbrains Mono Nerd Font` as the font. Pick a nice theme like `Catppuccin Mocha`, `Tokyo Night` or `Everforest`.

`ptyxis` is a great terminal, and works well with `distrobox`. You could use it as your main terminal.


### Generic Linux Desktop

This should work on almost any linux system/vm/container even without sudo privilege; You should have curl/wget and bash installed.


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
ilmi terminal jetbrains-mono
```

You can install vscode with

```bash
ilmi vscode jetbrains-mono
```

I will try to provide similar commands for immutable/nixos distributions in the future.


## Proxmox setup

This is an amazing hypervisor for almost anything. It's really simple to use, even if you don't know linux much. Just buy a minipc worth 150$ and install proxmox on it. You could learn a lot about linux, devops and cloud computing. I setup kubernetes clusters, docker/podman/lxc comtainers in multiple virtual machines without any problem. You could use Ceph if you need distributed storage for your cluster. Install desktop linux or windows if you need to. Passthrough your gpu to windows or bazzite and play games at close to bare metal fps.

Basic setup can be done with the following command.

```bash
bash -c "$(curl -sSL https://is.gd/epesoq)"
```

Once you are comfortable with proxmox, you should use ansible/terraform to create and provision virtual machines. I won't be providing any instructions for this anytime soon.

Similarly once you are comfortable with virtual machines on your desktop(libvirt), use ansible/packer to create and provision virtual machines.

You don't need to buy an expensive pc for any of this. Just buy a [8th/9th gen i5/i7 1 liter pc](https://www.servethehome.com/introducing-project-tinyminimicro-home-lab-revolution/) from ebay. You could get one for 50$-100$. You could even avoid buying a separate machine, and use this for both proxmox and desktop. I will provide instructions for this in the future.
