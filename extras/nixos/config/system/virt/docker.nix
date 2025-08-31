{ pkgs, vars, ... }:
{
  environment.systemPackages = with pkgs; [
    dive
    docker-compose
    docker-buildx
  ];

  networking.firewall.allowedTCPPorts = [
    9323
    2375
    2376
    8080
  ];

  virtualisation.podman.enable = false;

  networking.firewall.trustedInterfaces = [ "docker0" ];

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;

    autoPrune.enable = true;
    storageDriver = "btrfs";
    extraOptions = "--metrics-addr 0.0.0.0:9323";

    daemon.settings = {
      experimental = true;
      features.buildkit = true;
      log-driver = "json-file";
      log-opts = {
        max-size = "100m";
        max-file = "3";
      };
      default-ulimits = {
        nofile = {
          hard = 64000;
          soft = 64000;
        };
      };

      # Uncomment if you need custom address pools:
      # default-address-pools = [{
      #   base = "172.30.0.0/16";
      #   size = 24;
      # }];
    };

    # Rootless mode (optional)
    rootless = {
      enable = true;
      setSocketVariable = true;
    };

    users.extraGroups.docker.members = [ vars.username ];

    # Configure Docker registry mirrors (for faster pulls)
    # daemon.settings = {
    #   registry-mirrors = [
    #     "https://mirror.gcr.io"
    #   ];
    # };
  };

  # environment.variables = {
  #   DOCKER_BUILDKIT = "1";
  #   COMPOSE_DOCKER_CLI_BUILD = "1";
  # };

  # Enable Docker socket activation
  # This starts Docker daemon only when needed
  # systemd.sockets.docker.wantedBy = pkgs.lib.mkForce [];
  # systemd.services.docker.wantedBy = pkgs.lib.mkForce [];
}
