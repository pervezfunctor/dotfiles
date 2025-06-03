
## Dev Setup

Most development should happen in a container, either in a [devcontainer](https://code.visualstudio.com/docs/devcontainers/containers) or in a [distrobox](https://github.com/89luca89/distrobox). You could use the same scripts as above to setup shell.

For most development tools, use could use [mise](https://mise.dev). For python just use `uv`.

You could also install necessary tools and libraries for rust, go, c++ development using `installer`. I don't recommend this option.

Installer rust tools

```bash
ilmi rust
```

Install go tools

```bash
ilmi go
```

Install c++ tools

```bash
ilmi cpp
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

