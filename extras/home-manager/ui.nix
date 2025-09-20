{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    ghostty
    ptyxis
    vscode
    wl-clipboard
    nerd-fonts.jetbrains-mono
  ];
}
