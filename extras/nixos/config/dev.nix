{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    uv
    mise
    volta
  ];
}
