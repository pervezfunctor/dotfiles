{ pkgs, ... }:
{
  home.packages = with pkgs; [
    devbox
    devcontainer
    devenv
    volta
  ];
}
