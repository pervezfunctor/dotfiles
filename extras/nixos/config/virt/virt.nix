{ pkgs, ... }:
{
  imports = [
    ./common.nix
    ./libvirt.nix
    # ./incus.nix
    # ./cockpit.nix
    ./podman.nix
    ./virtualbox.nix
    # docker interferes with both podman and incus
    # ./docker.nix
  ];

  # virtualisation.microvm.enable = true;
  environment.systemPackages = with pkgs; [
    quickemu
  ];
}
