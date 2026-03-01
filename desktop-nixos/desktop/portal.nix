{ pkgs, ... }:
{
  xdg.portal = {
    enable = true;
    # extraPortals = with pkgs; [
    #   xdg-desktop-portal-wlr
    #   xdg-desktop-portal-hyprland
    #   xdg-desktop-portal-gnome
    #   xdg-desktop-portal-gtk
    # ];
    config = {
      common = {
        default = [
          "gnome"
          "gtk"
          "wlr"
          "hyprland"
        ];
        "org.freedesktop.impl.portal.Secret" = [
          "gnome-keyring"
        ];
      };
    };
  };
}
