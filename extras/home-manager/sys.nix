{ pkgs, ... }:
{
  home.packages = with pkgs; [
    bash
    coreutils
    curl
    file
    gcc
    git
    gnumake
    htop
    micro
    newt
    p7zip
    trash-cli
    tree
    fuse2
    fuse-overlayfs
    unzip
    wget
    xz
    zsh
    zstd
  ];
}
