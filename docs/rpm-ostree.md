
Fedora Atomic is great and the future of fedora if not linux in general. Unfortunately, atomic comes with almost nothing for developers and you have to use distrobox/toolbox for everything. This can be a frustrating experience. This will be a more stable operating system in practice than other approaches(conventional or ublue based).

### rpm-ostree based Setup

I would recommend you don't spend too much time configuring everything in a distrobox and spend multiple frustrating hours trying to get everything to work. Distrobox approach is still a work in progress, and hopefully in near future, this option will be simple. Until then, use `rpm-ostree` instead, as it's really easy to get it to work. Note that using rpm-ostree too many times is a bad idea. Refer to Fedora Atomic documentation about the best practices.

Install essential development tools like `vscode`, and `virt-manager` with the following command.

```bash
bash -c "$(curl -sSL https://is.gd/egitif)" -- rpm-ostree
```

After Installation, **reboot** your system and execute the following command.

```bash
ilmi rpm-ostree-post
```

**Reboot** Again. Check if vscode, virt-install are installed.

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
