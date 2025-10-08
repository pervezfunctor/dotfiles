{ pkgs, ... }:

{
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
  users.extraGroups.docker.members = [ "pervez" ];
  environment.systemPackages = with pkgs; [
    dive
    lazydocker
  ];
}
