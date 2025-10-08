{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    dialog
    newt
    openssl
    p7zip
    trash-cli
    tree
    unzip
    wget
    zstd
  ];
}
