## Notes

- You could install extensions using xargs

  ```bash
  cat <extensions-file> | xargs -L 1 code --install-extension # or
  cat <extensions-file> | xargs -L 1 flatpak run com.visualstudio.code --install-extension
  ```

- Hyper-V Windows Nested Virtualization

```powershell
Set-VMProcessor -VMName <VMName> -ExposeVirtualizationExtensions $true
```

- Install base from this repository

```bash
curl -s https://raw.githubusercontent.com/pervezfunctor/dotfiles/main/share/installers/setup | bash
```

- Might need to do the following in libvirt vm

```bash
sudo dnf install mesa-dri-drivers spice-vdagent  # Fedora
sudo apt install mesa-utils spice-vdagent        # Ubuntu/Debian
sudo zypper install Mesa-dri                     # openSUSE
sudo pacman -S mesa spice-vdagent                # Arch
```

-- create /etc/wsl.conf

```powershell
wsl.exe sh -c 'echo -e "[user]\ndefault=pervez" | sudo tee /etc/wsl.conf > /dev/null'

# following may work too

$wslConf = @"
[user]
default=pervez
"@

# Pass it into WSL and write with sudo
$command = "echo '$wslConf' | sudo tee /etc/wsl.conf > /dev/null"
wsl.exe sh -c "$command"

# or

wsl.exe --user root sh -c 'cat > /etc/wsl.conf <<EOF
[user]
default=pervez
EOF'

```
