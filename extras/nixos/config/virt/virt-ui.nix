{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
  ];

  imports = [
    ./virt.nix
    ./virtualbox.nix
    # ./vmware.nix
  ];
}
