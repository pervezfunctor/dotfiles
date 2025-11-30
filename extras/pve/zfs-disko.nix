{
  disko.devices = {
    disk.vmstore = {
      type = "disk";
      device = "/dev/sdb";
      content = {
        type = "zfs";
        pool = "vmstore";
      };
    };
  };

  # Configure dataset for VM storage
  boot.zfs.extraPools = [ "vmstore" ];

  fileSystems."/mnt/vmstore" = {
    device = "vmstore/vms";
    fsType = "zfs";
  };
}
