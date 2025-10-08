
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

- Open `~/.ilm/extras/nixos/config/vars.nix` and set `hostName`, `username`, `sshKey` and `initialPassword`.

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
mkdir -p ~/nix-config
cp -r ~/.ilm/extras/nixos/installer ~/nix-config
cp /etc/nixos/hardware-configuration.nix ~/nix-config
```

Edit configuration files, add/remove what you want. You could check `~/.ilm/extras/nixos/config` for reference.

Once you are happy with your configuration, run the following command.

```bash
nixos-rebuild switch --flake ~/nix-config\#<host-name> # hostname you picked in `vars.nix`
```

You could also use my configuration, but I won't recommend it. Add your host configuration to `flake.nix` in `~/.ilm/extras/nixos/config/flake.nix` and run the following command. This will also work if you used `NixOS Graphical installer`.

```bash
sudo nixos-rebuild switch --flake ~/.ilm/extras/nixos/config#<host-name>
```
