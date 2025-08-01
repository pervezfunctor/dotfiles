{ pkgs, ... }:
{
  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    alejandra
    bash
    coreutils
    curl
    gawk
    gcc
    git
    glibc
    gnugrep
    gnumake
    nixd
    nixfmt-rfc-style
    statix
    tcpdump
    vim
    wget
    xz
  ];
}
