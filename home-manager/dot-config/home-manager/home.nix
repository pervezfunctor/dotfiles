{ config, pkgs, ... }:

{
  home.username = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME";

  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

  home.packages = [
    pkgs.zsh
    pkgs.trash-cli
    pkgs.starship
    pkgs.gh
    pkgs.stow
    pkgs.just
    pkgs.ripgrep
    pkgs.zsh
    pkgs.fzf
    pkgs.delta
    pkgs.lazygit
    pkgs.eza
    pkgs.fd
    pkgs.zoxide
    pkgs.bat
    pkgs.tmux
    pkgs.neovim

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

  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    ".zshrc" = { source = ~/.ilm/zsh/dot-zshrc; };
    ".config/nvim" = { source = ~/.ilm/nvim/dot-config/nvim; };
    ".config/tmux" = {
        source = ~/.ilm/tmux/dot-config/tmux;
        recursive = true;
    };
    ".gitconfig" = { source = ~/.ilm/git/dot-gitconfig; };

    # ".config/Code/User/settings.json" = {
    #     source = ~/.ilm/extras/vscode/minimal-settings.json;
    #     copy = true;
    # };
    # ".emacs" = {
    #     source = ~/.ilm/emacs-slim/dot-eamcs;
    #     copy = true;
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
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.zsh.enable = true;
}
