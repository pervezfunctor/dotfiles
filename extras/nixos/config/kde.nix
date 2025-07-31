{ ... }:
{
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # environment.systemPackages = with pkgs.kdePackages; [ dolphin konsole kate ];
  # programs.plasma-manager.enable = true;

  # programs.plasma-manager.settings = {
  #   lookAndFeel = "org.kde.breeze.desktop";
  #   windowDecorations.theme = "Breeze";
  #   workspace.theme = "BreezeDark";
  #   cursorTheme.name = "Breeze_Snow";
  #   colorscheme = "BreezeDark";

  #   shortcuts = {
  #     "KWin" = {
  #       "Window Maximize" = [ "Meta+Up" ];
  #       "Window Minimize" = [ "Meta+Down" ];
  #     };
  #   };
  # };
}
