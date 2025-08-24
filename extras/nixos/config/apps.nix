{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    chromium
    deluge
    firefox
    obsidian
    telegram-desktop
    zoom-us
  ];
}
