{ config, pkgs, ... }: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  users.users.me = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "nixos";
  };

  system.stateVersion = "25.11";
}
