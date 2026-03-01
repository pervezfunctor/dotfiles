{ inputs, ... }:
{
  imports = [
    inputs.caelestia.homeManagerModules.default
  ];

  programs.caelestia = {
    enable = true;
    systemd = {
      enable = true;
      target = "wayland-session@Hyprland.target";
    };

    settings = {
      bar.status = {
        showBattery = false;
      };
      paths.wallpaperDir = "~/Pictures/Wallpapers";
    };

    cli = {
      enable = true;
      settings = {
        theme = {
          enableTerm = true;
          enableHypr = true;
          enableQt = true;
          enableGtk = true;
          enableIcons = true;
          enableCursor = true;
        };
      };
    };
  };
}
