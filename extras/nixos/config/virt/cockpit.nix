{ pkgs, ... }:

{
  services.cockpit = {
    enable = true;
    port = 9090;
    package = pkgs.cockpit.override {
      extraPackages = with pkgs; [
        cockpit-podman
        cockpit-machines
        cockpit-navigator
        cockpit-sosreport
      ];
    };
  };

  # Additional Cockpit plugins
  environment.systemPackages = with pkgs; [
    cockpit-file-sharing # File transfer
    cockpit-selinux # SELinux management
    cockpit-storaged # Storage management
    cockpit-kdump # Kernel crash analysis
    cockpit-packagekit # Package updates
  ];

  # # Configure reverse proxy (optional but recommended for HTTPS)
  # services.nginx = {
  #   enable = true;
  #   recommendedProxySettings = true;
  #   virtualHosts."cockpit.your-domain.com" = {
  #     forceSSL = true;
  #     enableACME = true;
  #     locations."/" = {
  #       proxyPass = "http://127.0.0.1:${toString config.services.cockpit.port}";
  #       proxyWebsockets = true;
  #     };
  #   };
  # };

  # # Security configuration
  # security = {
  #   pam.services.cockpit.text = "auth required pam_succeed_if.so user ingroup cockpit-ws"; # Restrict access
  #   acme.acceptTerms = true;
  #   acme.defaults.email = "admin@your-domain.com";
  # };

  # User groups for access control
  users.groups.cockpit-ws = { };
  users.users.yourusername.extraGroups = [
    "cockpit-ws"
    "docker"
    "incus-admin"
  ];

  # Firewall settings
  networking.firewall = {
    allowedTCPPorts = [
      80
      443
    ]; # For reverse proxy
    # If not using reverse proxy:
    # allowedTCPPorts = [ config.services.cockpit.port ];
    allowedTCPPortRanges = [
      {
        from = 9090;
        to = 9095;
      } # Cockpit dynamic ports
    ];
  };

  # Enable DBus services for full functionality
  services.dbus.packages = [ pkgs.cockpit ];

  # Systemd services for additional features
  # systemd.services.cockpit-ws = {
  #   serviceConfig = {
  #     RestrictAddressFamilies = [
  #       "AF_UNIX"
  #       "AF_INET"
  #       "AF_INET6"
  #     ]; # Security hardening
  #     MemoryDenyWriteExecute = true;
  #     LockPersonality = true;
  #   };
  # };
}
