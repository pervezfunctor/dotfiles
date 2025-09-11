{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
  ];

  imports = [
    ./vm.nix
    # ./virt/virtualbox.nix
    # ./virt/vmware.nix
  ];
}
