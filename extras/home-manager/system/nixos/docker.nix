{ pkgs, vars, ... }:

{
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
  users.extraGroups.docker.members = [ vars.username ];
  environment.systemPackages = with pkgs; [
    dive
    lazydocker
  ];
}
