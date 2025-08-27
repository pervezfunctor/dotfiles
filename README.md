# Development environment

## Installation on your current system

All the following commands are generally meant to be run on a freshly installed system. If you run it on an existing system, you will lose some of your existing configuration. You have been warned.

## TLDR

### Linux

Installs vscode, docker and shell tools

```bash
bash -c "$(curl -sSL https://is.gd/egitif || wget -qO- https://is.gd/egitif)" -- work
```

### MacOS

Installs homebrew, essential shell tools, vscode and docker.

```bash
curl https://pkgx.sh | sh
pkgx bash -c "$(curl -sSL https://is.gd/egitif)" -- work
```

### Windows

Pick what you want to install.

```powershell
iwr -useb https://is.gd/vefawu | iex
```

## Introduction

### Linux

On linux desktop(Ubuntu 25.04 for eg), install shell tools, vscode and docker with the following command. Works on Ubuntu 25.04, Fedora 42, OpenSUSE Tumbleweed, Debian Trixie and Arch.

```bash
bash -c "$(curl -sSL https://is.gd/egitif || wget -qO- https://is.gd/egitif)" -- work
```

If you only want to install modern unix tools in a development container/vm/desktop, use the following command instead. Works on linux and macos.

```bash
bash -c "$(curl -sSL https://is.gd/egitif || wget -qO- https://is.gd/egitif)" -- shell-slim
```

Or just install the very basic packages(gcc, make, tar, git etc)

```bash
bash -c "$(curl -sSL https://is.gd/egitif || wget -qO- https://is.gd/egitif)"
```

If you have an existing configuration, for many tools, you shouldn't run any of the commands in this README. You could still use some of the scripts here by adding the following to your ~/.bashrc or ~/.zshrc.


```bash
export PATH="$HOME/.local/bin:$HOME/.ilm/bin:$HOME/.ilm/bin/vt:$PATH"

source "$HOME/.ilm/share/utils"
source "$HOME/.ilm/share/fns"
```

If you need a nice prompt and a few other things, without installing anything, first you need to clone this repository to `~/.ilm`.

```bash
git clone https://github.com/pervezfunctor/dotfiles.git ~/.ilm
```

Then set your shell to zsh, if you haven't already. You could use the following command.

```bash
chsh -s $(which zsh)
```

Optionally, install [starship](https://starship.rs/). You would have a great experience if you install `fzf`, `zoxide` and `eza`.

Then add the following to your ~/.bashrc and ~/.zshrc.

```bash
source ~/.ilm/zsh/dot-zshrc # at the end of ~/.zshrc
source ~/.ilm/share/bashrc # at the end of ~/.bashrc
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

If you want to setup vscode and other development tools on Windows, run the following command in powershell **as administrator**. Install Windows updates first, if you haven't already.

```powershell
iwr -useb https://is.gd/vefawu | iex
```

You will be presented with a menu, pick what you want to install.

**Important Note**: I don't use Windows any more. I have not tested the above commands recently. They should work, but there might be some issues. Please let me know if you face any problems.

### MACOS

On macos, install applications(vscode, terminal, fonts etc) along with shell tools. Works on linux too.

```bash
curl https://pkgx.sh | sh
pkgx bash -c "$(curl -sSL https://is.gd/egitif)" -- shell-slim-ui
```

If you just want homebrew and basic unix tools, run the following command.

```bash
bash -c "$(curl -sSL https://is.gd/egitif)"
```

You could later use `ilmi` to install additional tools like `docker`, `vscode`, `tmux`, `nvim` etc.


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

If you have never used linux before, arch linux might not be the best choice.

If you want to learn how linux works and different moving parts in a linux desktop, you should try Arch Linux. You MUST install archlinux manually following the [Arch Wiki](https://wiki.archlinux.org/title/Installation_guide), at least once. You will learn a lot about linux, how it works, how to configure it, and how to troubleshoot issues.

You could later either use [archinstall](https://archinstall.readthedocs.io/en/latest/) or use a distriution like [CachyOS](https://cachyos.org/download/) to install arch linux.

Once installed, make sure you update your system. Use the following command.

```bash
sudo pacman -Syu --noconfirm
```

Reboot your system.

*One important note*. If you are comfortable with terminal, and know what you need exactly, then archlinux is the simplest installer you could use for linux. With almost everything else, you will need to figure out ways, how to install and configure things the way you want and it's usually can be really hard.


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
vm-create --distro debian --name dev --docker --username debian --password debian
```

After a few minutes, you should be able to ssh into this vm with the following command. If you don't have ssh key set up, this script will generate one for you.

```bash
vm ssh dev debian # debian is the user name
```

If you are not using Fedora, you need a better terminal. You could easily install `ptyxis` with the following command.

```bash
ilmi flathub ptyxis
```

Remember to pick `Jetbrains Mono Nerd Font` as the font. Pick a nice theme like `Catppuccin Mocha`, `Tokyo Night` or `Everforest`.

`ptyxis` is a great terminal, and works well with `distrobox`. You could use it as your main terminal.


## Recommended Setups

### Fedora Atomic(Silverblue, Kinoite, Sway Atomic)

Fedora Atomic is great and the future of fedora if not linux in general. Unfortunately, atomic comes with almost nothing for developers and you have to use distrobox/toolbox for everything. This can be a frustrating experience. This will be a more stable operating system in practice than any of the other approaches(traditional or ublue based). This OS is strictly NOT for those who like to tinker a lot.

###  Atomic Setup

IF you are a *purist*, then DO NOT use rpm-ostree, use distrobox for everything instead. I have multiple distrobox containers for different purposes. But they are brittle. Not everything works perfectly. Anyway, you could use the following command for such a setup.

```bash
bash -c "$(curl -sSL https://is.gd/egitif)" -- fedora-atomic
```

Above command should install some basic tools on the host, but developer tools(`vscode`, `docker` etc.) are inside a distrobox container.

I will add more instructions to use distrobox and toolbox in the future. For now, you could use the following commands to install some essential tools.

```bash
dboxe ilm # enter distrobox container
code # opens vscode from distrobox container
```

### rpm-ostree Setup

I would recommend you don't spend too much time configuring everything in a distrobox and spend multiple frustrating hours trying to get everything to work. This is still work in progress, and hopefully in near future, this option will be a reality. Until then, use `rpm-ostree` instead, as it's really easy to get this to work. You could just create a layer on top of atomic, using `rpm-ostree`, and that's what I am currently doing. Note that using rpm-ostree too many times is a bad idea. Refer to Fedora Atomic documentation about the best practices.

Install essential development tools like `vscode`, and `virt-manager` with the following command.

```bash
bash -c "$(curl -sSL https://is.gd/egitif)" -- rpm-ostree
```

If you need docker, you should install it in a vm, and use `vscode` to ssh into this virtual machine. `devconainers` work really well using this approach.

Generate ssh key, if you don't have it already.

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

Then create a vm with the following command. This will create a debian vm with docker, brew and dotfiles.

```bash
vm-create --distro debian --name dev --docker --brew --dotfiles --username debian --password debian min
```

You should not install anything on the host, once this is done. You could use `distrobox` for command line tools. Use flatpak for desktop applications. Use `devcontainers` for development from `vscode`. You could use `virt-install/virsh` or `virt-manager` to create and manage as many virtual machines as you want.


### Bluefin/Aurora/Bazzite

If you have some experience with linux desktop, and bored with fedora atomic, then you should try [Bluefin](https://projectbluefin.io) or [Aurora](https://getaurora.dev/en) or [Bazzite](https://bazzite.gg/). All based on [ublue](https://getublue.com) and have the same set of tools. Consider using dx version. You would get docker, vscode, by default.

Unfortunately, there is no direct ISO of dx version available. Either you rebase to dx version after installing regular version or use the [ublue template](https://github.com/ublue-os/image-template) and create your own custom ISO based on dx version. I will add instructions soon.

Once you have your OS installed, you could configure vscode and shell with the following command.

```bash
  bash -c "$(curl -sSL https://is.gd/hurace)"
```

### NixOS

If you are an experienced linux desktop user, and you have enough knowledge of linux and are a developer, then you should try `nixos`. There is a lot to learn and there will be very frustrating times. But it's worth it. IF you are into devops, and like IaC, then you would love nixos.

Unfortunately there is no easy way to make automated installers for nixos. You need to learn `nix` and understand the configurations. You have to tailor the configuration to your needs.

For installation use the minimal iso. DO NOT USE the default ISO, if this is your first time using nixos. Installation would be easy but you will struggle to get everything working as you expect. Use the minimal iso, and follow the [nixos installation guide](hhttps://nixos.org/manual/nixos/stable/#sec-installation-manual).


Some Instructions for setting up your NixOS system based on my dotfiles. *Work in progress*

First, boot with minimal iso. Once you are dropped to a shell, change to `root` user, and set a password.
**Importante Note**: You must have UEFI bootloader. You MUST disable secure boot.

```bash
sudo -i # should not ask for password
passwd  # note this password
```

Then note down your IP.

```bash
ip -brief a # note this ip
```

Once you are logged in(provide password you set above), you could check which disk to use with the following command.

```bash
lsblk -d # note the disk you want to use
```

Now get back to your laptop,

- clone this repository to your laptop.

```bash
git clone https://github.com/pervezfunctor/dotfiles.git ~/.ilm
```

- open `.ilm/extras/nixos/config/disko-config.nix` file and set `disko.devices.disk.main.device` to the disk you want to use(noted above), for eg `/dev/sda` or /dev/nvme0n1`.

- Open `~/.ilm/extras/nixos/config/vars.nix` and set `hostName`, `userName`, `sshKey` and `initialPassword`.

- You can make any changes you want, for example, add packages you would need after installation.

Now run the command from your laptop.

```bash
~/.ilm/extras/nixos/installer/remote-setup <ip> <hostname>
```

After installation completes you should be able to boot your remote system.

On you new `NixOS` system, do the following after you login(with gdm).

Open default terminal and run the following commands.

- set your password
```bash
passwd <user-name>
```

- generate default base configuration.

```bash
cd /etc/nixos
sudo nixos-generate-config
```

Either edit the above, and run the following

```bash
nixos-rebuild switch
```

Or use the same configuration used for the installer with the following.

```bash
git clone --depth=1 https://github.com/pervezfunctor/dotfiles.git ~/.ilm
mkdir -p ~/nixos-config
cp -r ~/.ilm/extras/nixos/installer ~/nixos-config
cp /etc/nixos/hardware-configuration.nix ~/nixos-config
```

Edit configuration files, add/remove what you want. You could check `~/.ilm/extras/nixos/config` for reference.

Once you are happy with your configuration, run the following command.

```bash
nixos-rebuild switch --flake ~/nixos-config#<host-name> # hostname you picked in `vars.nix`
```

You could also use my configuration, but I won't recommend it. Add your host configuration to `flake.nix` in `~/.ilm/extras/nixos/config/flake.nix` and run the following command. This will also work if you used `NixOS Graphical installer`.

```bash
sudo nixos-rebuild switch --flake ~/.ilm/extras/nixos/config#<host-name>
```

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
