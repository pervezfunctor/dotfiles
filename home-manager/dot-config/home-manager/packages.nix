{ pkgs, ... }:
{
  home.packages = with pkgs; [
    alejandra
    bat
    carapace
    delta
    devbox
    devenv
    gh
    gum
    jq
    just
    lazygit
    nixd
    nixfmt-rfc-style
    ripgrep
    stow
    tmux
    tealdeer
    trash-cli
    yazi
  ];
}
