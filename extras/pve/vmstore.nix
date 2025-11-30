{ config, lib, pkgs, ... }:

{
  options.vmstore = {
    enable = lib.mkEnableOption "VM storage disk";
    device = lib.mkOption {
      type = lib.types.str;
      description = "Disk device (/dev/sdb)";
    };
    fsType = lib.mkOption {
      type = lib.types.enum [ "btrfs" "zfs" ];
      default = "btrfs";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = "vmstore";
    };
    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };

  config = lib.mkIf config.vmstore.enable {

    users.groups.${config.vmstore.group} = { };

    users.users = lib.genAttrs config.vmstore.users (u: {
      extraGroups = [ config.vmstore.group ];
    });

    # BTRFS
    fileSystems = lib.mkIf (config.vmstore.fsType == "btrfs") {
      "/mnt/${config.vmstore.group}" = {
        device = "/dev/disk/by-label/${config.vmstore.group}";
        fsType = "btrfs";
        options = [ "compress=zstd" "autodefrag" ];
      };
    };

    # ZFS (auto-mount)
    boot.zfs.extraPools = lib.mkIf (config.vmstore.fsType == "zfs") [
      config.vmstore.group
    ];

    systemd.tmpfiles.rules = [
      "d /mnt/${config.vmstore.group} 2775 root ${config.vmstore.group} -"
      "d /mnt/${config.vmstore.group}/vms 2775 root ${config.vmstore.group} -"
    ];

    # Disable COW for VM images
    systemd.services."vmstore-disable-cow" = lib.mkIf (config.vmstore.fsType == "btrfs") {
      wantedBy = [ "multi-user.target" ];
      script = ''
        if [ -d /mnt/${config.vmstore.group}/vms ]; then
          chattr +C /mnt/${config.vmstore.group}/vms || true
        fi
      '';
      serviceConfig.Type = "oneshot";
    };
  };
}


# Enable in flake
# {
#   modules = [
#     ./modules/vmstore.nix
#   ];

#   vmstore = {
#     enable = true;
#     device = "/dev/sdb";
#     fsType = "btrfs";
#     group = "vmstore";
#     users = [ "pervez" "vmadmin" ];
#   };
# }
