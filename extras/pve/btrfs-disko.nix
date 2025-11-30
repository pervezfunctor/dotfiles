{
  disko.devices = {
    disk.vmstore = {
      type = "disk";
      device = "/dev/sdb";
      content = {
        type = "filesystem";  # also supports "zfs"
        format = "btrfs";     # or "zfs"
        label = "vmstore";
        mountpoint = "/mnt/vmstore";
        mountOptions = [ "compress=zstd" "autodefrag" ];
        extraArgs = [ "-f" ];
        subvolumes = {
          "vms" = { };
        };
      };
    };
  };
}
