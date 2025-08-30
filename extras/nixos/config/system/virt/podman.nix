{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    buildah
    ctop
    distrobox
    distroshelf
    fuse-overlayfs
    podman
    podman-compose
    podman-tui
    ptyxis
    skopeo
    slirp4netns
    toolbox
    # kubernetes-helm
    # kubectl
  ];

  virtualisation = {
    containers = {
      enable = true;
      registries.search = [
        "registry.fedoraproject.org"
        "registry.access.redhat.com"
        "quay.io"
        "docker.io"
      ];
    };

    podman = {
      enable = true;
      dockerCompat = false;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
      defaultNetwork.settings.dns_enabled = true;
    };
    quadlet = {
      containers = { };
      networks = { };
      pods = { };
      volumes = { };
    };
  };

  users.groups.podman = { };
  boot.kernel.sysctl."user.max_user_namespaces" = 28633;

  # virtualisation.podman.dockerSocket.enable = true;
  # systemd.enableUnifiedCgroupHierarchy = true;
  # security.unprivilegedUsernsClone = true;
  # boot.kernelModules = [ "overlay" ];
  # users.users.me = {
  #   # Required for rootless containers
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

  # # Systemd services for rootless Podman
  # systemd.user.services.podman = {
  #   enable = true;
  #   description = "Podman API Service";
  #   serviceConfig = {
  #     ExecStart = "${pkgs.podman}/bin/podman system service --time=0";
  #     Restart = "on-failure";
  #     TimeoutStopSec = 70;
  #   };
  #   wantedBy = [ "default.target" ];
  # };

  # # Cockpit integration for Podman
  # services.cockpit = {
  #   enable = true;
  #   package = pkgs.cockpit.override {
  #     extraPackages = with pkgs; [ cockpit-podman ];
  #   };
  # };

  # # Firewall configuration
  # networking.firewall = {
  #   trustedInterfaces = [ "podman0" ];
  #   allowedTCPPorts = [
  #     8080
  #     9090
  #   ]; # Example container ports
  # };

  # # Kernel modules for container features
  # boot.kernelModules = [
  #   "veth"
  #   "bridge"
  #   "overlay"
  #   "nft_nat"
  # ];

  # # Systemd settings for lingering sessions
  # systemd.extraConfig = ''
  #   DefaultTimeoutStartSec=90s
  #   DefaultTimeoutStopSec=90s
  # '';

  # # Podman auto-update timer
  # systemd.timers.podman-auto-update = {
  #   description = "Auto-update Podman containers";
  #   timerConfig = {
  #     OnCalendar = "daily";
  #     Persistent = true;
  #   };
  #   wantedBy = [ "timers.target" ];
  # };

  # systemd.services.podman-auto-update = {
  #   description = "Update Podman containers";
  #   serviceConfig = {
  #     Type = "oneshot";
  #     ExecStart = "${pkgs.podman}/bin/podman auto-update";
  #     User = "me"; # Run as non-root user
  #   };
  # };

  # # ZFS support (optional)
  # boot.supportedFilesystems = [ "zfs" ];
  # services.zfs.autoScrub.enable = true;
}
