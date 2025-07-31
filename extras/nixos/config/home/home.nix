{ pkgs, ... }:
{
  # home-manager.useUserPackages = true;
  # home-manager.useGlobalPkgs = true;

  home = {
    stateVersion = "25.11";
    username = "me";
    homeDirectory = "/home/me";

    packages = with pkgs; [
      alejandra
      bat
      carapace
      delta
      duf
      emacs-nox
      eza
      fd
      fzf
      gh
      htop
      just
      lazygit
      luarocks
      micro-with-wl-clipboard
      neovim
      nixd
      nushell
      ripgrep
      ripgrep
      sd
      shellcheck
      shfmt
      starship
      stow
      tealdeer
      tmux
      trash-cli
      tree
      unzip
      unzip
      yazi
      zoxide
      zsh
    ];
  };

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

  # sessionVariables = {
  #   SSH_AUTH_SOCK = "/run/user/1000/keyring/ssh";
  # };

  # file.".xprofile".text = ''
  #   eval $(gnome-keyring-daemon --start)
  #   export SSH_AUTH_SOCK
  # '';

  # pointerCursor = {
  #   name = "Adwaita";
  #   package = pkgs.adwaita-icon-theme;
  #   size = 24;
  #   x11 = {
  #     enable = true;
  #     defaultCursor = "Adwaita";
  #   };
  #   sway.enable = true;
  # };

  programs = {
    git = {
      enable = true;
      userName = "Pervez Iqbal";
      userEmail = "pervezfunctor@gmail.com";
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
    };
    bash.enable = true;
    # nushell.enable = true;
    bat.enable = true;
    ghostty.enable = true;
    home-manager.enable = true;
  };

  # dconf.settings = {
  #   "org/virt-manager/virt-manager/connections" = {
  #     autoconnect = [ "qemu:///system" ];
  #     uris = [ "qemu:///system" ];
  #   };
  # };

  # stylix = {
  #   enable = true;

  #   # base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";

  #   image = /home/me/.ilm/wallpapers/dot-config/wallpapers/wallpaper.png;
  #   polarity = "dark";
  # };
}
