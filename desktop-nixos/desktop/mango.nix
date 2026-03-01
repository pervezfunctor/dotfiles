{ inputs, pkgs, ... }:
{
  nixosModule = {
    programs.mango.enable = true;

    environment.systemPackages = with pkgs; [
      swayidle
    ];
  };

  homeModule = {
    imports = [
      inputs.mango.hmModules.mango
    ];

    systemd.user.targets.mango-session = {
      Unit = {
        Description = "mango compositor session";
        Requires = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
    };

    wayland.windowManager.mango = {
      enable = true;
    };

    home.file = {
      ".config/mango/config.conf" = {
        source = ../config/mango/config.conf;
        force = true;
      };
    };
  };
}
