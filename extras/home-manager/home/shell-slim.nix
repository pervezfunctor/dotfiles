{ pkgs, ... }:
{
  home.packages = with pkgs; [
    bat
    eza
    fzf
    gh
    gum
    newt
    ripgrep
    stow
    tmux
    trash-cli
    zoxide
  ];
}
