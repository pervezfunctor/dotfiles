{ pkgs, ... }:
{
  virtualisation.incus = {
    enable = true;
    preseed = {
      enable = true;
      config = ''
        config:
          core.https_address: '[::]:8443'
          core.trust_password: "CHANGE_ME_STRONG_PASSWORD"
        storage_pools:
          - name: default
            driver: zfs
            config:
              source: tank/incus
              zfs.pool_name: tank/incus
        networks:
          - name: lxdbr0
            type: bridge
            config:
              ipv4.address: auto
              ipv6.address: none
        profiles:
          - name: default
            devices:
              root:
                path: /
                pool: default
                type: disk
      '';
    };

    zfsSupport = true;
    recommendedSysctlSettings = true; # Optimizes kernel parameters
  };

  environment.systemPackages = with pkgs; [
    incus-ui-canonical
  ];

  networking.firewall = {
    allowedTCPPorts = [ 8443 ];
    trustedInterfaces = [ "lxdbr0" ];
  };

  incus.ui.enable = true; # Enable Incus web UI integration
  virtualisation.lxc.enable = true; # Required for Incus
}

# incus.preseed = {
#   networks = [{
#     config = {
#       "ipv4.address" = "10.0.100.1/24";
#       "ipv4.nat" = "true";
#     };
#     name = "incusbr0";
#     type = "bridge";
#   }];
#   profiles = [{
#     devices = {
#       eth0 = {
#         name = "eth0";
#         network = "incusbr0";
#         type = "nic";
#       };
#       root = {
#         path = "/";
#         pool = "default";
#         size = "35GiB";
#         type = "disk";
#       };
#     };
#     name = "default";
#   }];
#   storage_pools = [{
#     config = { source = "/var/lib/incus/storage-pools/default"; };
#     driver = "dir";
#     name = "default";
#   }];
