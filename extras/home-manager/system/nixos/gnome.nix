{ pkgs, ... }:
{
  services.displayManager.gdm.enable = true;
  services.displayManager.gdm.wayland.enable = true;
  services.desktopManager.gnome.enable = true;
  programs.dconf.enable = true;
}
