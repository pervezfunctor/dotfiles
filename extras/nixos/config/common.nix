{ pkgs, ... }:
{
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
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

  nix = {
    gc = {
      automatic = true;
      dates = "Sun 03:00";
      options = "--delete-older-than 5d";
      persistent = true;
      randomizedDelaySec = "30min";
    };

    settings = {
      auto-optimise-store = true;
      keep-build-log = true;
      keep-outputs = true;
      keep-derivations = true;

      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  nixpkgs.config.allowUnfree = true;
}
