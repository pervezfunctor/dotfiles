{ pkgs, vars, ... }:
{
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  programs = {
    bash.enable = true;
    nushell.enable = true;

    git = {
      enable = true;
      userName = "${vars.gitUserName}";
      userEmail = "${vars.gitUserEmail}";
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
    };

    eza.enable = true;
    fzf.enable = true;
    zoxide.enable = true;
    bat.enable = true;
  };

  home = {
    username = vars.username;
    homeDirectory = vars.homeDirectory;

    packages = with pkgs; [
      alejandra
      atuin
      bat
      carapace
      delta
      devbox
      devenv
      eza
      fd
      fzf
      gh
      gum
      htop
      jq
      just
      lazygit
      llama-cpp
      luarocks
      neovim
      nixd
      nixfmt-rfc-style
      nodejs
      nushell
      p7zip
      procs
      rclone
      ripgrep
      rsync
      sd
      shellcheck
      shfmt
      starship
      stow
      tealdeer
      television
      bottom
      trash-cli
      unar
      unzip
      xz
      yazi
      zoxide
    ];

    stateVersion = "25.11";
  };

  news.display = "silent";

  imports = [
    # ./sources.nix
  ];

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  # ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/<user-name>/etc/profile.d/hm-session-vars.sh
  #
}
