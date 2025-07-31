{ config, lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ehci_pci"
    "ahci"
    "nvme"
    "rtsx_pci_sdmmc"
    "usb_storage"
    "sd_mod"
    "sr_mod"
    "virtio_pci"
    "virtio_blk"
  ];

  boot.initrd.kernelModules = [ "dm-snapshot" "cryptd" "dm_mod" ];
  boot.kernelModules = [ "kvm-intel" ]; # Or "kvm-amd" if your host is AMD
  boot.extraModulePackages = [ ];

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.enableAllFirmware = true;
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

}
