{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    bitwarden
    concessio
    chromium
    deluge
    devtoolbox
    firefox
    obsidian
    telegram-desktop
    zoom-us
  ];
}
