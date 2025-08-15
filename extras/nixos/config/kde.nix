{ pkgs, ... }:
{
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;

  xdg.portal.extraPortals = pkgs.xdg-desktop-portal-kde;

  environment.systemPackages = with pkgs.kdePackages; [
    dolphin
  ];

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
