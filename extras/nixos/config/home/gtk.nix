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
    #   name = "Adwaita-dark";
    #   package = pkgs.gnome.gnome-themes-extra;
    # };

    # iconTheme = {
    #   name = "Adwaita";
    #   package = pkgs.gnome.adwaita-icon-theme;
    # };
  };
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
    "org/gnome/shell" = {
      disable-user-extensions = false;

      enabled-extensions = [
        "alphabetical-app-grid@just-perfection.github.com"
        "appindicatorsupport@rgcjonas.gmail.com"
        "blur-my-shell@aunetx"
        "coverflow-alt-tab@just-perfection.github.com"
        "gsconnect@andyholmes.github.io"
        "just-perfection@just-perfection.github.com"
        "paperwm@paperwm.github.io"
        "tailscale-status@marcel-dierkes.de"
        "tiling-assistant@gnome-shell-extensions.gcampax.github.com"
        "undecorate@gnome-shell-extensions.gcampax.github.com"
        "user-themes@gnome-shell-extensions.gcampax.github.com"
        "Vitals@CoreCoding.com"
        "windows-navigator@gnome-shell-extensions.gcampax.github.com"
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
