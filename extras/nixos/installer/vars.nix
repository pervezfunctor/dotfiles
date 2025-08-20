{ pkgs, ... }:

{
  hostName = "nixos";
  userName = "me";
  initialPassword = "nixos";

  sshKey = "<ssh-key>";

  shell = pkgs.zsh;
  # shell = pkgs.bash;

  diskoMainDisk = "<host-disk>"; # like "/dev/nvme0n1";
  diskoSwapSize = "8G";
}
