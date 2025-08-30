{ pkgs, ... }:
{
  # goes against nixos philosophy but useful for me.
  # Use devenv instead. nix develop is good too
  environment.systemPackages = with pkgs; [
    uv
    mise
    volta
  ];
}
