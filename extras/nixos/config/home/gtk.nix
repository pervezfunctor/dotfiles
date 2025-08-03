{ ... }:
{
  gtk = {
    enable = true;

    # theme = {
    #   name = "Adwaita-dark";
    #   package = pkgs.gnome.gnome-themes-extra;
    # };

    # iconTheme = {
    #   name = "Adwaita";
    #   package = pkgs.gnome.adwaita-icon-theme;
    # };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
      gtk-overlay-scrolling = false;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
      gtk-overlay-scrolling = false;
    };
  };

  dconf.settings = {
    "org/gnome/desktop/input-sources" = {
      xkb-options = [ "caps:ctrl_modifier" ];
    };

    "org/gnome/desktop/screensaver" = {
      lock-enabled = false;
    };

    # "org/gnome/desktop/session" = {
    #   idle-delay = 0; #  disables screen blanking
    # };

    "org/gnome/desktop/interface" = {
      gtk-theme = "Adwaita-dark";
      icon-theme = "Adwaita-dark";
      cursor-theme = "Adwaita";
      color-scheme = "prefer-dark";
      gtk-key-theme = "Emacs";
      accent-color = "purple";
      monospace-font-name = "JetbrainsMono Nerd Font 11";
    };

    "org/gnome/mutter" = {
      dynamic-workspaces = false;
      center-new-windows = true;
    };

    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 4;
    };

    "org/gnome/mutter" = {
      experimental-features = [ "scale-monitor-framebuffer" ];
    };
  };
}
