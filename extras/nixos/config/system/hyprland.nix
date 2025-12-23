{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    withUWSM = true; # recommended for most users
    xwayland.enable = false;
  };

  services.gnome.gnome-keyring.enable = true;
  environment.systemPackages = with pkgs; [
    font-awesome
    mako
    hyprcursor
    hypridle
    hyprlock
    hyprpaper
    kitty
    networkmanagerapplet
    rofi
    swaynotificationcenter
    waybar
    wl-clipboard
    wlogout
  ];
}
