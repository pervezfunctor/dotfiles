{ config, pkgs, ... }:

{
  # This is for WSL nixos. So default username should be fine.
  home.username = "nixos";
  home.homeDirectory = "/home/nixos";
  home.stateVersion = "25.11";

  # programs.git = {
  #   enable = true;
  #   userName = "Pervez Iqbal";
  #   userEmail = "pervezfunctor@gmail.com";
  # };

  home.packages = with pkgs; [
    bat
    carapace
    coreutils
    curl
    delta
    dialog
    eza
    fd
    fzf
    gawk
    gcc
    gh
    git
    glibc
    gnugrep
    gnumake
    htop
    just
    lazygit
    luarocks
    micro
    neovim
    newt
    nixfmt-rfc-style
    nixd
    nushell
    ripgrep
    sd
    shellcheck
    shfmt
    stow
    tmux
    trash-cli
    tree
    unzip
    wget
    zoxide
    zstd
  ];

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      update-os = "sudo nixos-rebuild switch --flake ~/.ilm/extras/nixos-wsl/nixos\#";
    };
    initContent = ''
      source ~/.ilm/share/shellrc
    '';
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      source ~/.ilm/share/shellrc
    '';
  };

  nixpkgs.config.allowUnfree = true;

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.home-manager.enable = true;
}
