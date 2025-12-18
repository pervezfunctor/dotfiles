{ ... }:
{
  # services.displayManager.gdm.enable = true;
  programs.niri = {
    enable = true;
    settings = {
      input = {
        keyboard = {
          xkb.layout = "us";
          xkb.kb_options = "caps:ctrl_modifier";
        };
      };

      layout = {
        gaps = 8;
      };

      bar = {
        enable = false;

      };

      binds = {
        "Mod+Return" = {
          spawn = "ghostty";
        };
        "Mod+Q" = {
          close-window = true;
        };

        "Mod+Shift+E" = {
          quit = true;
        };
      };
    };
  };
}
