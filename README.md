# Development environment

## TLDR

On linux desktop, to get started quickly, use the following command.

```bash
bash -c "$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)" -- dev
```


If within a linux container, use the following command.

```bash
bash -c "$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)" -- shell
```


## Windows Setup


Following script is tested on a fresh install of Windows 11 Pro.

Open `powershell` as administrator and run the following command. You will be asked to enter `username` and `password` to setup `CentOS` which you will need later.

```powershell
iwr -useb https://dub.sh/kIv4BnI | iex
```

After the above scripts ends, you must do the following

1. Reboot your system.

2. Open Windows Terminal. Open settings(`Ctrl+,`) and set font to `JetbrainsMono Nerd Font` for `CentOS-Stream-10` and `Powershell` profiles or preferably in defaults profile.

3. Above script will setup `CentOS` Stream 10(`wsl`). To access it, either use `Windows Terminal` profile or use the following command.

```bash
wsl -d CentOS-Stream-10
```

4. Change your default shell to `zsh`.

```bash
chsh -s $(which zsh) $USER
zsh
```

5. Start `tmux`. This will take a little bit of time to install plugins. Be patient.

```bash
tmux
```

4. Start neovim to check all is okay. You can always use `:checkhealth` for diagnostics in nvim.

```bash
nvim
```

5. Open `vscode`, from `CentOS-Stream-10` wsl. Go to extensions, and install extension neovim(`asvetliakov.vscode-neovim`) in WSL(CentOS-Stream-10)).


If the above script does not work, you could manually set up windows wsl(Ubuntu) environment, using the following commands.

```powershell
    wsl --install -d Ubuntu-24.04
```

Reboot your computer. Then use the following commands.

    wsl -d Ubuntu-24.04
    # run the following within wsl
    bash -c "$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)" -- shell
```

If you want to install all WSL distributions available and setup multipass along with a decent windows powershell configuration, use the following command.

Install windows updates first. This might require reboot.

```powershell
iex "& { $(iwr -useb https://dub.sh/NDyiu7a) } -Components windows-update"
```

Install WSL next. You might have to reboot again.

```powershell
iex "& { $(iwr -useb https://dub.sh/NDyiu7a) -Components wsl }"
```

Install ubuntu wsl.

```powershell
iex "& { $(iwr -useb https://dub.sh/NDyiu7a) -Components wsl-ubuntu }"
```

If you want multipass. You might have to reboot again.

```powershell
iex "& { $(iwr -useb https://dub.sh/NDyiu7a) -Components multipass }"
```

Install multipass vm.

```powershell
iex "& { $(iwr -useb https://dub.sh/NDyiu7a) -Components multipass-vm }"
```

Install the folowing for sure.

```powershell
iex "& { $(iwr -useb https://dub.sh/NDyiu7a) -Components nerd-fonts vscode }"
```

If you want to install everything, use the following command .
```
iex "& { $(iwr -useb https://dub.sh/NDyiu7a) -Components all }"
```

Or pick and choose.

```powershell
iwr -useb https://dub.sh/NDyiu7a | iex
```

## Recommended Setup


### ublue

If you are an experienced linux user and and an experienced developer, then [Aurora](https://getaurora.dev/en) or [Bluefin](https://projectbluefin.io) would be perfect. Bluefin and Aurora are based on Fedora Atomic.

  - Install shell tools using [homebrew](https://brew.sh), which is comparable to `nix` or `aur` in package selection. You also get the latest versions of packages.

  - Install desktop apps using [flatpak](https://flathub.org), most modern apps on linux are available.

  - [Visual studio code](https://code.visualstudio.com) is installed and configured properly.

  - Use [docker](https://docker.com) or [podman](https://podman.io)(open source) for containers.

  - Use [distrobox](https://distrobox.it) for software development. You could use scripts from [Alternate setup](#alternate-setup) to setup the container.

  - [libvirt](https://libvirt.org)/[virt-manager](https://virt-manager.org) for virtual machines.

  - [incus](https://linuxcontainers.org/incus) for virtual machines and [lxc(stateful)](https://linuxcontainers.org/lxc) containers.

Install and configure shell tools and desktop apps using the following command. Works only on bluefin and aurora.

```bash
bash -c "$(curl -sSL https://dub.sh/Hr0YTqp || wget -qO- https://dub.sh/Hr0YTqp)"
```


### Fedora Atomic

If you prefer Fedora Atomic([Kinoite](https://fedoraproject.org/atomic-desktops/kinoite) or [Silverblue](https://fedoraproject.org/atomic-desktops/kinoite)), then use the following command. If you prefer an immutable OS along with a tiling window manager, then [Fedora Sway Atomic](https://fedoraproject.org/atomic-desktops/sway) is an excellent option.

```bash
bash -c "$(curl -sSL https://dub.sh/RCrpnUm || wget -qO- https://dub.sh/RCrpnUm)"
```

  - Use [distrobox](https://distrobox.it) for everything. Default distrobox is setup with zsh and shell utilies, gnome-keyring, visual studio code and firefox(needed for authentication).

  - You can also install visual studio code using flatpak.

  - Use [Ptyxis](https://gitlab.gnome.org/chergert/ptyxis) terminal, as it has great support for toolbox.


## Alternate setup

**Note**: All of the following scripts should work fine on most flavors of `Ubuntu`, `Fedora`(except Atomic), `Debian`, `Rocky`, `Arch` and `Opensuse Tumbleweed`.

If you are a beginner linux developer, use Fedora Workstation, it's awesome! If you need Ubuntu, take a look at [Rhino Linux](https://rhinolinux.org). Make sure you select container and virtualization tools in the post install dialog. Rhinos uses xfce, perfect for low end laptops.

If you are an experienced linux developer, but don't want to use immutable distributions, I would recommend Opensuse Tumbleweed, a rolling release distribution similar to Arch Linux, but simpler and a bit more stable.

Install and configure shell tools with the following command.

```bash
bash -c "$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)" -- shell
```

Install container and virtualization tools(in addition to above shell tools and configuration), with following command.

```bash
bash -c "$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)" -- vm
```

Install desktop apps including vscode(in addition to above), with the following command.

```bash
bash -c "$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)" -- desktop
```

You could also, first install the base setup

```bash
bash -c "$(curl -sSL https://dub.sh/aPKPT8V || wget -qO- https://dub.sh/aPKPT8V)"
```

and then at any point(after reboot), use `ilm-group-installer`.

```bash
ilm-group-installer
ilm-group-installer help
```

You could pick from `shell`, `ct`, `vm`, `desktop` and `dev` groups.

`shell` will install and configure zsh and bash(with [starship](https://starship.rs) prompt), neovim(with lazyvim](http://www.lazyvim.org)) and [tmux](https://github.com/tmux/tmux/wiki). Installs modern shell tools like

- [gh - github cli](https://cli.github.com)
- [just - task runner](https://github.com/casey/just)
- [fzf - fuzzy finder](https://github.com/junegunn/fzf)
- [zoxide - smart cd](https://github.com/ajeetdsouza/zoxide)
- [fd - find](https://github.com/sharkdp/fd)
- [eza - modern ls](https://github.com/eza-community/eza)
- [bat - modern cat](https://github.com/sharkdp/bat)
- [delta - git diff](https://github.com/dandavison/delta)

Following optional utilities might also be installed

- [lazygit - git ui](https://github.com/jesseduffield/lazygit)
- [procs - modern ps](https://github.com/dalance/procs)
- [sd - modern sed](https://github.com/chmln/sd)
- [xh - modern httpie](https://github.com/ducaale/xh)
- [bottom - modern top](https://github.com/ClementTsang/bottom)
- [duf - modern df](https://github.com/muesli/duf)
- [cheat - cheat sheet](https://github.com/cheat/cheat)

`ct` will install the following, along with `shell` packages above.

- [podman](https://podman.io)
- [incus](https://linuxcontainers.org/incus)
- [docker](https://docker.com)
- [portainer](https://portainer.io)
- [lazydocker](https://github.com/jesseduffield/lazydocker)

`desktop` will install the following, along with `shell` packages above.

- [Ptyxis terminal](https://gitlab.gnome.org/chergert/ptyxis) or [ghostty terminal](https://github.com/pgdev92/ghostty)
- [vscode editor](https://code.visualstudio.com)
- [jetbrains mono nerd font](https://github.com/ryanoasis/nerd-fonts)
- apps(like [zoom](https://zoom.us), [obsidian](https://obsidian.md), chromium etc)

In addition to the above group installs, you could also use `installer` to setup various tools like `emacs`.

```bash
ilm-installer
```

Pass `help` to get all options and short descriptions, run

```bash
ilm-installer help
```

## Container Setup

Most development should happen in a container, either in a [devcontainer](https://code.visualstudio.com/docs/devcontainers/containers) or in a [distrobox](https://github.com/89luca89/distrobox). You could use the same scripts as above to setup shell.

For most development tools, use could use [mise](https://mise.dev). For python just use `uv`.

You could also install necessary tools and libraries for rust, go, c++ development using `installer`. I don't recommend this option.

Installer rust tools

```bash
ilm-installer rust
```

Install go tools

```bash
ilm-installer go
```

Install c++ tools

```bash
ilm-installer cpp
```

## Only dotfiles(Advanced)

I use [stow](https://www.gnu.org/software/stow) with this repository. If you know what you are doing, and make sure all the software needed is installed, you could use stow to get your system configured. For eg.

```bash
git clone https://github.com/pervezfunctor/dotfiles.git ~/.ilm
cd ~/.ilm
stow share bin # this is required
stow zsh
stow emacs nvim sway # folder names
```

**NOte**: Ubuntu has older version of stow and might not work properly. Use stow version >= 2.4.x.


## Tips

1. [Don’t change your login shell, use a modern terminal emulator](https://tim.siosm.fr/blog/2023/12/22/dont-change-defaut-login-shell/)

2. Fix locale issues on Ubuntu with the following command.

  ```bash
  sudo dpkg-reconfigure locales
  ```

3. Use `imwheel` to fix mouse-scroll speed on Ubuntu in VMware.

  ```bash
  imwheel -b "4 5" > /dev/null 2>&1
  ```

4. In `opensuse` you could use the following command to get all the patterns(group for dnf)

  ```bash
  zypper search --type pattern
  ```


# OS recommendations

1. If you need Ubuntu, use [kubuntu](https://kubuntu.org/feature-tour)

2. If you want Gnome, use [Bluefin](https://projectbluefin.io) or [Fedora Workstation](https://fedoraproject.org/workstation/)

3. If you want KDE, use [Tumbleweed](https://get.opensuse.org/tumbleweed) or [Aurora](https://getaurora.dev/en)

4. If you want a tiling window manager, use [Fedora Sway](https://fedoraproject.org/spins/sway) or [Suseway](https://get.opensuse.org/tumbleweed)] or [hyprland](https://hyprland.org/)

5. If you want to run linux desktop environment in a virtual machine, then [kubuntu](https://kubuntu.org/feature-tour) is more stable.

6. For containers prefer debian or ubuntu.

7. For development only containers, you could use fedora and tumbleweed, especially if you don't want to use `brew` or `nix`.

7. Give [Nix](https://nixos.org) a try.
