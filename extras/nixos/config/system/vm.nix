{ pkgs, ... }:
{
  imports = [
    ./virt/common.nix
    ./virt/libvirt.nix
    ./virt/podman.nix
    # ./virt/incus.nix
    ./virt/cockpit.nix
    # docker interferes with both podman and incus
    # ./virt/docker.nix
  ];

  # virtualisation.microvm.enable = true;
  environment.systemPackages = with pkgs; [
    quickemu
  ];
}
