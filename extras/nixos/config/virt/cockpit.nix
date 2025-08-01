{ pkgs, ... }:

{
  services.cockpit = {
    enable = true;
    port = 9090;
    # package = pkgs.cockpit.override {
    #   extraPackages = with pkgs; [
    #     cockpit-podman
    #     cockpit-machines
    #     cockpit-navigator
    #     cockpit-sosreport
    #     cockpit-file-sharing
    #     cockpit-selinux
    #     cockpit-storaged
    #     cockpit-kdump
    #     cockpit-packagekit
    #   ];
    # };
  };

  # User groups for access control
  users.groups.cockpit-ws = { };

  # Firewall settings
  networking.firewall = {
    allowedTCPPortRanges = [
      {
        from = 9090;
        to = 9095;
      } # Cockpit dynamic ports
    ];
  };

  # Enable DBus services for full functionality
  services.dbus.packages = [ pkgs.cockpit ];

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
