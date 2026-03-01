{ pkgs, ... }:
{
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    qbittorrent
    telegram-desktop
    zoom-us
    vivaldi
    vulkan-tools
  ];
}

# On KDE
# (vivaldi.override {
#   commandLineArgs = "--password-store=kwallet6";
# })
