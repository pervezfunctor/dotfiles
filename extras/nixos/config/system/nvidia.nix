{ config, ... }:
{
  services.xserver.videoDrivers = [ "nvidia" ];
  open = false;
  nvidiaSettings = true;
  package = config.boot.kernelPackages.nvidiaPackages.stable;

  hardware = {
    graphics = {
      enable = true;
    };
    nvidia = {
      modesetting.enable = true;

      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      # Enable this if you have graphical corruption issues or application crashes after waking
      # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
      # of just the bare essentials.
      powerManagement.enable = false;

      # Fine-grained power management. Turns off GPU when not in use.
      # Experimental and only works on modern Nvidia GPUs (Turing or newer).
      powerManagement.finegrained = false;
    };
  };
}
