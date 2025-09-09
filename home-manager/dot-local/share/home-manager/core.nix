{ pkgs, ... }:
{
  home.packages = with pkgs; [
    alejandra
    nixd
    nixfmt-rfc-style
    devbox
    devenv
  ];
}
