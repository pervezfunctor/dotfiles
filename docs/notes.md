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
