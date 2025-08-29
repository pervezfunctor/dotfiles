
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
