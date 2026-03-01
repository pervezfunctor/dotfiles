{ pkgs, ... }:
{
  nixosModule = {
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };

    environment.systemPackages = with pkgs; [
      swaylock-effects
      swayidle
      # mako
    ];
  };

  # environment.sessionVariables = {
  #   XDG_CURRENT_DESKTOP = "sway";
  #   XDG_SESSION_TYPE = "wayland";
  # };

  homeModule = {
    home.pointerCursor.sway.enable = true;

    home.file = {
      ".config/sway/config" = {
        source = ../config/sway/config;
        force = true;
      };
    };
    # in case sway is launched from terminal
    # wayland.windowManager.sway.systemd.variables = ["--all"];
  };
}

# without displaymanager autologin to sway on tty1
# services.getty = {
#   autologinUser = "your_username";
#   autologinOnce = true;
# };
# environment.loginShellInit = ''
#     [[ "$(tty)" == /dev/tty1 ]] && sway
# '';
