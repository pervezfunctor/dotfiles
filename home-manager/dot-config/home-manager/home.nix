{ pkgs, ... }:

{
  home.username = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME";

  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  home.packages = with pkgs; [
    bat
    carapace
    delta
    emacs-nox
    eza
    fd
    fzf
    just
    lazygit
    luarocks
    neovim
    nixpkgs-fmt
    nodejs
    ripgrep
    sd
    starship
    stow
    tealdeer
    unzip
    yazi
    zoxide

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      source ~/.ilm/share/bashrc
    '';
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.git.enable = true;
  programs.zsh.enable = true;

  home.file = {
    ".zshrc" = {
      source = "${builtins.getEnv "HOME"}/.ilm/zsh/dot-zshrc";
    };
    ".config/nvim" = {
      source = "${builtins.getEnv "HOME"}/.ilm/nvim/dot-config/nvim";
    };
    ".config/tmux/tmux.conf" = {
      source = "${builtins.getEnv "HOME"}/.ilm/tmux/dot-config/tmux/tmux.conf";
    };
    ".gitconfig" = {
      source = "${builtins.getEnv "HOME"}/.ilm/git/dot-gitconfig";
    };
    ".emacs" = {
      source = "${builtins.getEnv "HOME"}/.ilm/emacs-nano/dot-emacs";
    };
    # ".config/Code/User/settings.json" = {
    #     source = ${builtins.getEnv "HOME"}/.ilm/extras/vscode/minimal-settings.json;
    # };

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

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
  home.sessionVariables = {
    EDITOR = "code --wait";
  };
}
