{ pkgs, ... }:
{
  imports = [
    ./core.nix
  ];

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
