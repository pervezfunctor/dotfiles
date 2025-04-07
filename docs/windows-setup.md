
## Windows Development Environment

## Recommended Setup

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

Install multipass. You need to reboot again, unless you installed wsl using the above script.

```powershell
iex "& { $(iwr -useb https://dub.sh/NDyiu7a) -Components multipass }"
```

Install multipass vm.

```powershell
iex "& { $(iwr -useb https://dub.sh/NDyiu7a) -Components multipass-vm }"
```

Install nerd fonts. Without this most modern linux/wsl tools won't work.

```powershell
iex "& { $(iwr -useb https://dub.sh/NDyiu7a) -Components nerd-fonts }"
```

Install vscode.

```powershell
iex "& { $(iwr -useb https://dub.sh/NDyiu7a) -Components vscode }"
```

If you want to install everything.

```
iex "& { $(iwr -useb https://dub.sh/NDyiu7a) -Components all }"
```

Or pick and choose.

```powershell
iwr -useb https://dub.sh/NDyiu7a | iex
```

## Centos WSL Based Setup

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
