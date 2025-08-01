{ pkgs, ... }:
{
  imports = [
    ./common.nix
    ./libvirt.nix
    ./incus.nix
    ./cockpit.nix
    ./docker.nix
  ];

  # virtualisation.microvm.enable = true;
  environment.systemPackages = with pkgs; [
    quickemu
  ];
}
