{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    bash
    coreutils
    curl
    file
    gawk
    gcc
    git
    gnumake
    micro
    fuse2
    fuse-overlayfs
    zsh
  ];
}
