{ ... }:
{
  imports = [
    ./docker.nix
    ./libvirt.nix
    ./nixos.nix
    ./podman.nix
    ./vmware.nix
  ];
}
