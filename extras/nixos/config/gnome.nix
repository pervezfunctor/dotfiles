{ pkgs, ... }:
{
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  programs.dconf.enable = true;
  programs.gnome-terminal.enable = true;

  environment.systemPackages = with pkgs; [
    gnome-software
  ];
}
