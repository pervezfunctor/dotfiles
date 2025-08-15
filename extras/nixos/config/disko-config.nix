let
  btrfsOpts = [
    "noatime"
    "compress=zstd"
    "space_cache=v2"
    "ssd"
    "discard=async"
  ];
in
{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/vdb";
    content = {
      type = "gpt";
      partitions = {
        EFI = {
          size = "512M"; # Reduced EFI size
          type = "ef00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        SWAP = {
          size = "2G"; # Much smaller swap
          type = "8200";
          content = {
            type = "swap";
          };
        };
        ROOT = {
          size = "100%";
          type = "8300";
          content = {
            type = "btrfs";
            extraArgs = [ "-f" ];
            mountpoint = "/";
            mountOptions = btrfsOpts ++ [ "subvol=@" ];
            subvolumes = {
              "@".mountpoint = "/";
              "@nix" = {
                mountpoint = "/nix";
                mountOptions = btrfsOpts ++ [ "subvol=@nix" ];
              };
              "@home" = {
                mountpoint = "/home";
                mountOptions = btrfsOpts ++ [ "subvol=@home" ];
              };
              "@log" = {
                mountpoint = "/var/log";
                mountOptions = btrfsOpts ++ [ "subvol=@log" ];
              };
              "@snapshots" = {
                mountpoint = "/.snapshots";
                mountOptions = btrfsOpts ++ [ "subvol=@snapshots" ];
              };
            };
          };
        };
      };
    };
  };
}
