# Development environment

## Installation on your current system

### TLDR

## Linux

Installs vscode, docker and shell tools

```bash
bash -c "$(curl -sSL https://is.gd/egitif || wget -qO- https://is.gd/egitif)" -- dev
```

## MacOS

Installs homebrew and essential unix tools.

```bash
curl https://pkgx.sh | sh
pkgx bash -c "$(curl -sSL https://is.gd/egitif)"
```

## Windows

Pick and choose what you want to install.

```powershell
iwr -useb https://is.gd/vefawu | iex
```

### Linux

On linux desktop(Ubuntu 25.04 for eg), install shell tools, vscode and docker with the following command. Works on Ubuntu 25.04, Fedora 42, OpenSUSE Tumbleweed and Arch.

```bash
bash -c "$(curl -sSL https://is.gd/egitif || wget -qO- https://is.gd/egitif)" -- dev
```

If you only want to install modern unix tools in a development container/vm/desktop, use the following command instead. Works on linux and macos.

```bash
bash -c "$(curl -sSL https://is.gd/egitif || wget -qO- https://is.gd/egitif)" -- shell-slim
```

Or just install the very basic packages(gcc, make, tar, git etc)

```bash
bash -c "$(curl -sSL https://is.gd/egitif || wget -qO- https://is.gd/egitif)"
```

### Windows

On windows, use WSL. Install WSL, use  the following command.

```powershell
wsl --install --no-distribution
```

I recommend fedora for development. You could also use Ubuntu 24.04.

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


## Recommended Setups

If you are a developer, I would highly recommend using linux on your personal desktop. There are interesting things in happening in this space. As a developer you will have a lot of fun. This is stable enough.

If you don't have a personal desktop, just buy a mini pc. You could get a decent minipc for $300-$400. Even a nuc could cost less than 500$. You could use it as a desktop, development machine or a server. If you fine with a server that's capable of docker, you could buy N100/N150 mini pc, which should be around 150$. You would be surprised how much such a cheap machine can do.

I have stopped using Windows for anything. I hardly use macos. I use linux on almost all my machines, servers, homelab or personal desktop.

### Fedora Workstation

Fedora Workstation/Fedora KDE/Fedora Sway are all good choices. They are stable, have the latest kernel supporting most modern hardware. Most software is latest. This has the right balance of stability and latest software.

Download fedora workstation from [here](https://getfedora.org/en/workstation/download/) and install it on a separate disk. DO NOT use dual boot.

Once installation is done(which is pretty fast and easy), on first boot, make sure you enable third party repositories. This will allow you to install nvidia drivers and proprietary codecs. If you forgot to enable third party repositories, you could do so later [manually](https://rpmfusion.org/Configuration).

Once nvidia drivers and codecs are installed, update your system. Use the following command.

```bash
sudo dnf update -y
```
Reboot your system.

You could install modern shell tools with the following command.

```bash
bash -c "$(curl -sSL https://is.gd/egitif)" -- shell-slim
```

This command should setup your zsh, tmux and install tools like `ripgrep`, `eza`, `fzf`, `zoxide`, `bat`, `git-delta` etc.

As a developer you might need vscode. Install it with the following command.

```bash
ilmi vscode fonts
```

This will install `vscode` and `nerd fonts`. It should also install some essential extensions.

If you need docker, I would highly recommend you install it in a vm. IF you prefer to install it on your host, you could use the following command.

```bash
ilmi docker
```
You should be able to use `vscode` and `devcontainers` without any issues. Remember to reboot after installing docker.

I would highly recommend you install `libvirt` and `virt-manager` for managing virtual machines. You could use the following command.

```bash
ilmi vm-ui
```

Once you reboot, you should be able to create and use virtual machines.

I have a few helper scripts to make creating headless virtual machines easier. For example you could easily create a fedora vm with ssh enabled, using the following command.

```bash
vm-create --distro fedora --name dev
```

After a few minutes, you should be able to ssh into this vm with the following command. User name is `fedora` for ubuntu vm. If needed use password `fedora`.

```bash
vm ssh dev fedora
```
You could install docker and shell tools in this vm with the following command.

```bash
bash -c "$(curl -sSL https://is.gd/egitif)" -- shell-slim docker
```

All of the above instructions should work equally well for ubuntu, debian trixie, arch or tumbleweed. You need to install curl on debian/ubuntu. 

You might want a better terminal. On any linux you could easily install `ptyxis` with the following command.

```bash
ilmi flathub ptyxis
```

Remember to pick `Jetbrains Mono Nerd Font` as the font. Pick a nice theme like `Catppuccin Mocha`, `Tokyo Night` or `Everforest`.


### Fedora Atomic(Silverblue, Kinoite, Sway Atomic)

Fedora Atomic is great and the future of fedora if not linux in general. Unfortunately, atomic comes with almost nothing for developers and you have to use distrobox/toolbox for everything. This can be a frustrating experience. This will be a more stable operating system in practice than any of the other approaches(traditional or ublue based). This OS is strictly NOT for those who like to tinker a lot.

###  Atomic Setup

IF you are a *purist*, I have multiple distrobox containers, to get everything I need, but they are a bit brittle. Use the following command for such a setup.

```bash
bash -c "$(curl -sSL https://is.gd/egitif)" -- fedora-atomic
```

Above command should install some basic tools on the host, but developer tools(`vscode`, `docker`) are inside distrobox container. 

### rpm-ostree setup

I would recommend you don't spend too much time configuring everything in a distrobox and spend multiple frustrating hours trying to get it to work. Instead use `rpm-ostree` as it's really easy. You could create a layer on top of atomic, using `rpm-ostree`, and that's what I am currently doing. Note that calling rpm-ostree multiple times is a bad idea. Refer to Fedora Atomic documentation.
 
Install essential development tools like `vscode`, and `virt-manager` with the following command.

```bash
bash -c "$(curl -sSL https://is.gd/egitif)" -- rpm-ostree
```

If you need docker, you should install it in a vm, use `vscode` and ssh into this virtual machine. `devconainers` work really well using this approach.

```bash
vm-create --distro ubuntu --name dev --docker --brew --dotfiles min
```

### ublue based Bluefin/Aurora

If you have some experience with linux desktop, and bored with fedora atomic, then you should try [Bluefin](https://projectbluefin.io) or [Aurora](https://getaurora.dev/en). Both are based on [ublue](https://getublue.com) and have the same set of tools. Consider using dx version. You would get docker, vscode, libvirt/virt-manager by default. As a developer these tools are essential.

Unfortunately, there is no direct ISO of dx version available. Either you rebase to dx version after installing regular version or use the `ublue template` and create your own custom ISO based on dx version. I will add instructions soon.

### NixOS

If you are an experienced linux desktop user, and you have enough knowledge of linux and are a developer, then you should try `nixos`. There is a lot to learn and there will be very frustrating times. But it's worth it. IF you are into devops, and like IaC, then you would love nixos.

Unfortunately there is no easy way to make automated installers for nixos. You need to learn `nix` and understand the configurations. You have to tailor the configuration to your needs. I will write a guide soon, as soon as I get everything working as I expect. At present you could look at my *work in progress* config at `extras/nixos/config`. But, please don't judge me. :-)


### Linux Desktop

This should work on almost any linux system/vm/container even without sudo privilege; You should have curl/wget and bash installed.

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

If you are in distrobox or a virtual machine with desktop environment, you could install terminal with

```bash
ilmi terminal fonts
```

You can install vscode with

```bash
ilmi vscode fonts
```

I will try to provide similar commands for immutable/nixos distributions.

## Proxmox setup

This is an amazing hypervisor for almost anything. It's really simple to use, even if you don't know linux much. Just buy a minipc worth 150$ and install proxmox on it. You could learn a lot about linux, devops and cloud computing. I setup kubernetes clusters, docker/podman/lxc comtainers in multiple virtual machines without any problem. You could use Ceph if you need distributed storage for your cluster. Install desktop linux or windows if you need to. Passthrough your gpu to windows or bazzite and play games at close to bare metal fps.

Basic setup can be done with the following command.

```bash
bash -c "$(curl -sSL https://is.gd/epesoq)"
```
