{ pkgs, ... }:
{
  virtualisation.podman = {
    enable = true;

    # # Rootless configuration (recommended)
    # dockerSocket.enable = true;
    # dockerCompat = true; # Creates 'docker' alias for Podman

    defaultNetwork.settings.dns_enabled = true;
    # Systemd integration for container management
    enableSocketActivation = true;
    autoUpdate = true;

    # Resource limits
    extraPackages = [ pkgs.zfs ]; # For ZFS storage support
  };

  boot.kernel.sysctl."user.max_user_namespaces" = 28633; # Required for rootless containers

  virtualisation.containers = {
    storage.settings = {
      storage = {
        driver = "overlay";
        runroot = "/run/podman";
        graphroot = "/var/lib/podman/storage";
        options.overlay.ignore_chown_errors = "true";
      };
    };
  };

  # # User configuration for rootless operation
  # users.users.me = {
  #   isNormalUser = true;
  #   extraGroups = [ "podman" ];
  #   subUidRanges = [
  #     {
  #       startUid = 100000;
  #       count = 65536;
  #     }
  #   ];
  #   subGidRanges = [
  #     {
  #       startGid = 100000;
  #       count = 65536;
  #     }
  #   ];
  # };

  # Systemd services for rootless Podman
  systemd.user.services.podman = {
    enable = true;
    description = "Podman API Service";
    serviceConfig = {
      ExecStart = "${pkgs.podman}/bin/podman system service --time=0";
      Restart = "on-failure";
      TimeoutStopSec = 70;
    };
    wantedBy = [ "default.target" ];
  };

  # Podman-compose support
  environment.systemPackages = with pkgs; [
    podman-compose
    buildah # Image building tool
    skopeo # Image management
    dive # Image analysis
  ];

  # Cockpit integration for Podman
  services.cockpit = {
    enable = true;
    package = pkgs.cockpit.override {
      extraPackages = with pkgs; [ cockpit-podman ];
    };
  };

  # Firewall configuration
  networking.firewall = {
    trustedInterfaces = [ "podman0" ];
    allowedTCPPorts = [
      8080
      9090
    ]; # Example container ports
  };

  # Kernel modules for container features
  boot.kernelModules = [
    "veth"
    "bridge"
    "overlay"
    "nft_nat"
  ];

  # Systemd settings for lingering sessions
  systemd.extraConfig = ''
    DefaultTimeoutStartSec=90s
    DefaultTimeoutStopSec=90s
  '';

  # Podman auto-update timer
  systemd.timers.podman-auto-update = {
    description = "Auto-update Podman containers";
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
    wantedBy = [ "timers.target" ];
  };

  systemd.services.podman-auto-update = {
    description = "Update Podman containers";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.podman}/bin/podman auto-update";
      User = "me"; # Run as non-root user
    };
  };

  # ZFS support (optional)
  boot.supportedFilesystems = [ "zfs" ];
  services.zfs.autoScrub.enable = true;
}
