{ pkgs, ... }:

{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;

    autoPrune.enable = true;
    storageDriver = "btrfs";
    extraOptions = "--metrics-addr 0.0.0.0:9323";

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
    networking.firewall.trustedInterfaces = [ "docker0" ];

    virtualisation.podman.enable = false;

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
    # rootless = {
    #   enable = true;
    #   setSocketVariable = true;
    # };
  };

  # environment.variables = {
  #   DOCKER_BUILDKIT = "1";
  #   COMPOSE_DOCKER_CLI_BUILD = "1";
  # };

  # networking.firewall = {
  #   # Allow Docker to manage firewall rules
  #   checkReversePath = false;
  # };

  # Optional: Configure storage for Docker
  # This is useful if you want to store Docker data on a specific partition
  # systemd.tmpfiles.rules = [
  #   "d /var/lib/docker 0755 root root -"
  # ];

  # Optional: Enable Docker socket activation
  # This starts Docker daemon only when needed
  # systemd.sockets.docker.wantedBy = pkgs.lib.mkForce [];
  # systemd.services.docker.wantedBy = pkgs.lib.mkForce [];

  # Optional: Configure Docker registry mirrors (for faster pulls)
  # virtualisation.docker.daemon.settings = {
  #   registry-mirrors = [
  #     "https://mirror.gcr.io"
  #   ];
  # };
}
