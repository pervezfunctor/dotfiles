{ lib, ... }:
{
  fileSystems."/" = lib.mkDefault {
    device = "none";
    fsType = "tmpfs";
  };

  boot.loader.grub.enable = lib.mkForce false;
}
