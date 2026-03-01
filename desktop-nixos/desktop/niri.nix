{ pkgs, ... }:
{
  nixosModule = {
    programs.niri = {
      enable = true;
      useNautilus = true;
    };

    environment.systemPackages = with pkgs; [
      fuzzel
      swayidle
    ];

  };

  # environment.sessionVariables = {
  #   XDG_CURRENT_DESKTOP = "niri";
  #   XDG_SESSION_TYPE = "wayland";
  # };

  homeModule = {
    home.file = {
      ".config/niri/config.kdl" = {
        source = ../config/niri/config.kdl;
        force = true;
      };
    };
  };
}
