{ pkgs, ... }:
{
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
  boot.extraModprobeConfig = "options kvm_intel nested=1";
  boot.kernelPackages = pkgs.linuxPackages_latest;

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  services.xserver = {
    xkb = {
      layout = "us";
      options = "caps:ctrl_modifier";
    };
  };

  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_US.UTF-8";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;
}
