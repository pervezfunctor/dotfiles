{ pkgs, ... }:
{
  # home-manager.useUserPackages = true;
  # home-manager.useGlobalPkgs = true;

  imports = [
    ./zsh.nix
  ];

  home = {
    stateVersion = "25.11";
    username = "me";
    homeDirectory = "/home/me";

    packages = with pkgs; [
      alejandra
      atuin
      bacon
      cargo-info
      delta
      delta
      du-dust
      dua
      duf
      espanso
      evil-helix
      fastfetch
      fd
      fselect
      gh
      gitui
      htop
      hurl
      hyperfine
      just
      kondo
      lazygit
      mask
      micro-with-wl-clipboard
      mprocs
      ncspot
      nixd
      presenterm
      ripgrep
      ripgrep-all
      rtx
      rusty-man
      sd
      shellcheck
      shfmt
      stow
      tealdeer
      tokei
      trash-cli
      tree
      unzip
      wiki-tui
      yazi
      zellij
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
      # @TODO: Change these values
      userName = "Pervez Iqbal";
      userEmail = "pervezfunctor@gmail.com";
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
    };

    bash.enable = true;
    bat.enable = true;
    ghostty.enable = true;
    home-manager.enable = true;
    carapace.enable = true;
    direnv.enable = true;
    emacs.enable = true;
    eza.enable = true;
    fzf.enable = true;
    neovim.enable = true;
    nushell.enable = true;
    tmux.enable = true;
    yazi.enable = true;
    zoxide.enable = true;
    # programs.vscode.enable = true;

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
