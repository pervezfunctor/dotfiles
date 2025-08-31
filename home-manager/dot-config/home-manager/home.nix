{ pkgs, vars, ... }:

let
  aliases = {
    hms = "nix run home-manager -- switch --flake ~/.ilm/home-manager/dot-config/home-manager#${vars.username} --impure -b bak";
  };

  initContent = ''
    if [[ -d "$HOME/.ilm" ]]; then
      export PATH="$HOME/.volta/bin:$HOME/.local/bin:$HOME/.ilm/bin:$HOME/.ilm/bin/vt:$PATH"

      source "$HOME/.ilm/share/utils"
      source "$HOME/.ilm/share/fns"
      source "$HOME/.ilm/share/aliases"
    fi
  '';

in
{
  home.username = vars.username;
  home.homeDirectory = vars.homeDirectory;

  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    alejandra
    bat
    carapace
    delta
    devbox
    devenv
    eza
    fzf
    gh
    gum
    jq
    just
    lazygit
    nixd
    nixfmt-rfc-style
    ripgrep
    stow
    tealdeer
    trash-cli
    yazi
    zoxide
  ];

  programs.home-manager.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = aliases;
    initContent = initContent;
  };

  # home.file = {
  #   ".config/tmux/tmux.conf" = {
  #     source = ~/.ilm/tmux/dot-config/tmux/tmux.conf;
  #   };
  # };
}
