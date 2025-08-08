{ pkgs, ... }:
{

  gtk = {
    enable = true;

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
      gtk-overlay-scrolling = false;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
      gtk-overlay-scrolling = false;
    };

    # "org/gnome/desktop/session" = {
    #   idle-delay = 0; #  disables screen blanking
    # };
    # "org/gnome/settings-daemon/plugins/power" = {
    #   sleep-inactive-ac-type = "nothing";
    # };

    # theme = {
    #   name = "Nordic";
    #   package = pkgs.nordic;
    # };

    # iconTheme = {
    #   name = "Adwaita";
    #   package = pkgs.gnome.adwaita-icon-theme;
    # };
  };

  # qt = {
  #   enable = true;
  #   platformTheme = "qtct";
  #   style = "kvantum";
  # };

  home.packages = with pkgs.gnomeExtensions; [
    alphabetical-app-grid
    appindicator
    blur-my-shell
    coverflow-alt-tab
    gsconnect
    just-perfection
    paperwm
    tailscale-status
    tiling-assistant
    undecorate
    user-themes
    vitals
    # windows-navigator
  ];

  dconf.settings = {
    # iconTheme = {
    #   name = "Papirus-Dark";
    #   package = pkgs.papirus-icon-theme;
    # };

    # theme = {
    #   name = "palenight";
    #   package = pkgs.palenight-theme;
    # };

    # cursorTheme = {
    #   name = "Numix-Cursor";
    #   package = pkgs.numix-cursor-theme;
    # };

    "org/gnome/shell" = {
      disable-user-extensions = false;

      enabled-extensions = with pkgs.gnomeExtensions; [
        alphabetical-app-grid.extensionUuid
        appindicator.extensionUuid
        blur-my-shell.extensionUuid
        coverflow-alt-tab.extensionUuid
        gsconnect.extensionUuid
        just-perfection.extensionUuid
        paperwm.extensionUuid
        tailscale-status.extensionUuid
        tiling-assistant.extensionUuid
        undecorate.extensionUuid
        user-themes.extensionUuid
        vitals.extensionUuid
      ];
    };

    "org/gnome/desktop/input-sources" = {
      xkb-options = [ "caps:ctrl_modifier" ];
    };

    "org/gnome/desktop/screensaver" = {
      lock-enabled = false;
    };
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

    "org/gnome/shell/extensions/dash-to-dock" = {
      dock-position = "BOTTOM";
      dash-max-icon-size = 48;
    };
  };
}
