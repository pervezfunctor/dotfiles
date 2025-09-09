{ pkgs, ... }:
{
  imports = [
    ./core.nix
  ];

  home.packages = with pkgs; [
    bat
    carapace
    delta
    eza
    fd
    fzf
    gh
    gum
    jq
    just
    lazygit
    micro
    ripgrep
    stow
    tmux
    trash-cli
    yazi
    zoxide
  ];
}
