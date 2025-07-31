{ config, pkgs, ... }: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  users.users.me = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "nixos";
  };

  system.stateVersion = "25.11";
}
