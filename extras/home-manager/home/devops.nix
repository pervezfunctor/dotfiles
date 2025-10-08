{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ansible
    packer
  ];
}
