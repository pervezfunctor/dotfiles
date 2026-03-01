{ pkgs, ... }:
{
  nixosModule = {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = false;
    };

    environment.systemPackages = with pkgs; [
      hyprcursor
      hyprlauncher
      hyprlock
      hyprsysteminfo
      hyprsunset
      hyprpolkitagent
      hyprland-qt-support
      hyprpwcenter
      hyprpaper
      hypridle
    ];
  };

  homeModule = {
    home.file = {
      ".config/hypr/hyprland.conf" = {
        source = ../config/hypr/hyprland.conf;
        force = true;
      };
    };
  };
}
