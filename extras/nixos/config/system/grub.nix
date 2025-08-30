{ ... }:

{
  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      efiSupport = true;
      useOSProber = false;
      version = 2;
      device = "/dev/sda";
      extraConfig = ''
        GRUB_CMDLINE_LINUX_DEFAULT="quiet"
      '';
    };
  };
}
