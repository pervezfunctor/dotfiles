{ pkgs, ... }:

{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true; # Start Docker on system boot
    autoPrune.enable = true; # Automatically remove unused resources
    daemon.settings = {
      # Custom daemon.json configuration
      experimental = true; # Enable experimental features
      log-driver = "json-file";
      log-opts = {
        max-size = "100m";
        max-file = "3";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    docker-compose
    dive
  ];

  networking.firewall.allowedTCPPorts = [
    2375
    2376
  ];
  networking.firewall.trustedInterfaces = [ "docker0" ];
  # networking.firewall.allowedTCPPorts = [ 80 443 ];

  virtualisation.podman.enable = false;

  docker.extraOptions = "--metrics-addr 0.0.0.0:9323"; # Enable metrics for Cockpit
}
