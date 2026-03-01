{ pkgs, ... }:
{
  nixosModule = {
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;
    security.pam.services.gdm.enableGnomeKeyring = true;
    programs.dconf.enable = true;

    environment.systemPackages = with pkgs; [
      gnomeExtensions.paperwm
      gnomeExtensions.user-themes
      gnomeExtensions.switcher
      gnomeExtensions.open-bar
      gnomeExtensions.search-light
      gnomeExtensions.windownavigator
      gnomeExtensions.just-perfection
      # gnomeExtensions.blur-my-shell
      # gnomeExtensions.coverflow-alt-tab
      # gnomeExtensions.undecorate
      # gnomeExtensions.vitals
      # gnomeExtensions.switch-workspace
      # gnomeExtensions.focus-follows-workspace
    ];

    # To disable installing GNOME's suite of applications
    # and only be left with GNOME shell.
    services.gnome.core-apps.enable = false;
    services.gnome.core-developer-tools.enable = false;
    services.gnome.games.enable = false;
    environment.gnome.excludePackages = with pkgs; [
      gnome-tour
      gnome-user-docs
    ];

    # environment.sessionVariables = {
    #   XDG_CURRENT_DESKTOP = "Gnome";
    # };
  };

  homeModule = { };
}
