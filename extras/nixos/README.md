# NixOS Remote Installation

This repository provides a set of scripts to install NixOS on a remote machine.

## Installation Steps

1. **Clone the Repository:**

    ```bash
    git clone https://github.com/pervezfunctor/nixos-remote-install.git
    cd nixos-remote-install
    ```
2.  Setup you SSH Key in `config/user.nix` directly.

3.  **Build the ISO:**

    ```bash
    nix build .#iso
    ```

    This will create a bootable ISO image in the `result/` directory.

4.  **Boot the ISO:**

    Boot the target machine from the generated ISO. You can do this by writing the ISO to a USB drive or by using a virtual machine.

5.  **Connect to the Installer:**

    Once the machine has booted, you can connect to it via SSH. The root user is configured to allow SSH access with the same public key as the `me` user.

    ```bash
    ssh root@<ip-address>
    ```

    If you have not setup SSH keys, you can set a password with `passwd root`. And then run the above.

6.  **Partition the Disk:**

    Once connected, you need to partition the disk. You have two options:

    *   **Standard Partitioning:**

        ```bash
        ./installer/partition --disk /dev/vda
        ```

    *   **Encrypted Partitioning:**

        ```bash
        ./installer/crypt-partitions --disk /dev/vda
        ```

    Replace `/dev/vda` with the actual disk you want to install NixOS on. Use `lsblk -d` to find the correct disk.
    Or use the following command
        ```bash
        ls /dev/sd* /dev/nvme*n* 2>/dev/null | grep -v '[0-9]

        ```

    **WARNING: This is a destructive operation.**

7.  **Install NixOS:**

    After partitioning the disk, you can install NixOS using one of the following configurations:

    *   `server`: A basic server installation.
    *   `gnome`: A desktop installation with the GNOME desktop environment.
    *   `kde`: A desktop installation with the KDE Plasma desktop environment.
    *   `sway`: A desktop installation with the Sway tiling window manager.
    *   `gnome-vm`: A GNOME desktop installation for a virtual machine.
    *   `kde-vm`: A KDE Plasma installation for a virtual machine.
    *   `sway-vm`: A Sway installation for a virtual machine.

    To install, run the following command:

    ```bash
    ./installer/install <configuration>
    ```

    For example, to install the GNOME desktop environment, you would run:

    ```bash
    ./installer/install gnome
    ```

8.  **Reboot:**

    Once the installation is complete, you can reboot the machine.

    ```bash
    reboot
    ```

## Home Manager

After the installation, you can use `home-manager` to manage your user-level configuration. The configuration is located in the `hms/` directory.

To apply the `home-manager` configuration, run the following command from within the `hms` directory:

```bash
home-manager switch --flake .#me
```

## Testing with a VM

You can test the installation process in a virtual machine using the `build-vm` script:
It will generate ISO first using the configuration in `flake.nix` and `iso.nix`.

```bash
./build-vm
./result/bin/run-nixos-vm
```
