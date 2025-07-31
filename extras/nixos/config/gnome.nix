{ pkgs, ... }:
{
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  programs.dconf.enable = true;
  programs.gnome-terminal.enable = true;

  environment.systemPackages = with pkgs.gnomeExtensions; [
    user-themes
    blur-my-shell
    gsconnect
    # appindicator
    # windows-navigator
    vitals
    tailscale-status
    tiling-assistant
    coverflow-alt-tab
    just-perfection
    blur-my-shell
    undecorate
    alphabetical-app-grid
  ];
}
