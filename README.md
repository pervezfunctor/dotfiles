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

I have stopped using Windows for anything. I hardly use macos. I use linux on almost all my machines, servers, homelab or desktops.

If you have never used linux on desktop before, then you should consider either using Fedora Workstation or Kubuntu. Opt for kubuntu if you have very limited knowledge of linux, especially if you have an nvidia card. For both fedora and ubuntu/kubuntu you could follow the `linux` instructions above.

### ublue based Bluefin/Aurora

If you have some experience with linux desktop, then you could try [Bluefin](https://projectbluefin.io) or [Aurora](https://getaurora.dev/en). Both are based on [ublue](https://getublue.com) and have same set of tools. Consider using dx version. You would get docker, vscode, libvirt/virt-manager by default. As a developer these tools are essential.

Unfortunately, there is no direct ISO of dx version available. Either you rebase to dx version after installing regular version or use the `ublue template` and create your own custom ISO based on dx version.

### NixOS

If you are an experienced linux desktop user, and you have enough knowledge of linux and are a developer, then you should try `nixos`. There is a lot to learn and there will be very frustrating times. But it's worth it. IF you are into devops, and like IaC, then you would love nixos.

Unfortunately there is no easy way to make automated installers for nixos. You need to learn `nix` and understand the configurations. You have to tailor the configuration to your needs. I will write a guide soon, as soon as I get everything working as I expect. At present you could look at my *work in progress* config at `extras/nixos/config`.

### Fedora Atomic

Fedora Atomic is good too. Unfortunately, comes with almost nothing for developers and you will be forced to use distrobox/toolbox for everything. This is nowhere near good enough for developers.

You could create a layer on top of it, using `rpm-ostree`, that's what I am currently doing. This is really easy too but less *pure*. This will be a more stable operating system in practice than any of the other approaches. This OS is strictly NOT for those like to tinker a lot.

I personally use all of these operating systems(ublue, nixos, fedora atomic). I also use tumbleweed.

  - [Silverblue](https://fedoraproject.org/atomic-desktops/silverblue) with gnome 48 is a great choice. The best gnome experience you can get.
  - [Kinoite](https://fedoraproject.org/atomic-desktops/kinoite) if you prefer KDE. This is rock solid stable.
  - [Fedora Sway Atomic](https://fedoraproject.org/atomic-desktops/sway) if you prefer a tiling window manager. It might be a bit difficult to get vscode play well with sway. My configuration works fine as of now.

```bash
bash -c "$(curl -sSL https://is.gd/egitif)" -- rpm-ostree
```

You should install docker in a vm. Use `vscode` and ssh into this machine. `devconainers` work really well using this approach.

If you DO NOT want to use rpm-ostree, you could use the following command.

```bash
bash -c "$(curl -sSL https://is.gd/egitif)" -- generic
```

In future, I will add a distrobox container for docker, vscode, incus and libvirt. Currently with the above setup, you won't have docker. You could install ubuntu server in vm and configure docker there.

#### Recommendations

  - Use [distrobox](https://distrobox.it) for everything. Default distrobox is setup with zsh and shell utilities, gnome-keyring, vscode and firefox.

  - Use [Ptyxis](https://gitlab.gnome.org/chergert/ptyxis) terminal, as it has great support for distrobox and toolbox.

  - Use [Boxes](https://apps.gnome.org/Boxes) for simple virtual machines. Remember to enable 3d acceleration.


### Linux Desktop

This should work on almost any linux system/container even without sudo privilege; You should have curl/wget and bash installed. Not recommended on macos.

```bash
bash -c "$(curl -sSL https://is.gd/egitif || wget -qO- https://is.gd/egitif)" -- generic
```

If you don't have a personal desktop, just buy a mini pc. You could get a decent minipc for $300-$400. Even a nuc could cost less than 500$. You could use it as a desktop, development machine or a server. If you fine with a server that's capable of docker, you could buy N100/N150 mini pc, which should be around 150$. You would be surprised how much such a cheap machine can do.

## Linux Development Container/VM

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
ilmi terminal
```

You might be able to install vscode with

```bash
ilmi vscode
```

## Proxmox setup

This is an amazing operating system for almost anything. It's really simple, even if you don't know linux much. Just buy a minipc worth 150$ and install proxmox on it. You could learn a lot about linux, devops and cloud computing.

```bash
bash -c "$(curl -sSL https://is.gd/epesoq)"
```
