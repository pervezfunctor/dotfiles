{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nixfmt-rfc-style
    bash
    coreutils
    curl
    gawk
    gcc
    git
    glibc
    gnugrep
    gnumake
    statix
    vim
    wget
    xz
  ];
}
