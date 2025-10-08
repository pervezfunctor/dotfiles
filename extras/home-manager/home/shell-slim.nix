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
    starship
    stow
    tmux
    trash-cli
    zoxide
  ];
}
