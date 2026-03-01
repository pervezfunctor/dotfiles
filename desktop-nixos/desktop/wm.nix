{ pkgs, ... }:
{
  environment.systemPackages = import ./wm-packages.nix { inherit pkgs; };
  environment.pathsToLink = [ "/share/backgrounds/nixos" ];
}
