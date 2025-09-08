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
    curl
    delta
    emacs-nox
    eza
    fd
    fzf
    gcc
    gh
    git
    gnumake
    htop
    just
    lazygit
    luarocks
    neovim
    nixfmt-classic
    nushell
    ripgrep
    sd
    starship
    stow
    tmux
    trash-cli
    tree
    unzip
    wget
    zoxide
    zsh
  ];

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.zsh = { enable = true; };

  programs.bash = {
    enable = true;
    initExtra = ''
      source ~/.ilm/share/bashrc
    '';
  };

  nixpkgs.config.allowUnfree = true;

  home.sessionVariables = { EDITOR = "nvim"; };

  programs.home-manager.enable = true;
}
