{ config, pkgs, ... }:

{
  # This is for WSL nixos. So default username should be fine.
  home.username = "nixos";
  home.homeDirectory = "/home/nixos";

  # DO NOT CHANGE THIS
  home.stateVersion = "25.05";

  home.packages = [
    pkgs.bat
    pkgs.carapace
    pkgs.curl
    pkgs.delta
    pkgs.emacs-nox
    pkgs.eza
    pkgs.fd
    pkgs.fzf
    pkgs.gcc
    pkgs.gh
    pkgs.git
    pkgs.gnumake
    pkgs.htop
    pkgs.just
    pkgs.lazygit
    pkgs.luarocks
    pkgs.neovim
    pkgs.nixfmt-classic
    pkgs.nushell
    pkgs.ripgrep
    pkgs.sd
    pkgs.starship
    pkgs.stow
    pkgs.tmux
    pkgs.trash-cli
    pkgs.tree
    pkgs.unzip
    pkgs.wget
    pkgs.zoxide
    pkgs.zsh
  ];

  # programs.git = {
  #   enable = true;
  #   userName = "Pervez Iqbal";
  #   userEmail = "pervefunctor@gmail.com";
  # };

  programs.zsh.enable = true;

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      source ~/.ilm/share/bashrc
    '';
  };

  nixpkgs.config.allowUnfree = true;

  home.file = {
    ".zshrc" = { source = ~/.ilm/zsh/dot-zshrc; };
    ".config/nvim" = { source = ~/.ilm/nvim/dot-config/nvim; };
    ".config/tmux/tmux.conf" = {
      source = ~/.ilm/tmux/dot-config/tmux/tmux.conf;
    };
    ".gitconfig" = { source = ~/.ilm/git/dot-gitconfig; };
    ".emacs" = { source = ~/.ilm/emacs-nano/dot-emacs; };
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/nixos/etc/profile.d/hm-session-vars.sh
  #

  home.sessionVariables = { EDITOR = "nvim"; };

  programs.home-manager.enable = true;

  # programs.nushell = {
  #   enable = true;
  #   # Optional configuration
  #   configFile.source = ~/.ilm/nushell/dot-config/nushell/config.nu;
  #   envFile.source = ~/.ilm/nushell/dot-config/nushell/env.nu;
  # };
}
