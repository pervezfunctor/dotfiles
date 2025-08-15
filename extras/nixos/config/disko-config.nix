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
    device = "/dev/vda"; # Replace with actual disk device (e.g., /dev/sda)
    content = {
      type = "gpt";
      partitions = {
        EFI = {
          size = "1G";
          type = "ef00";
          content = {
            type = "filesystem";
            format = "vfat";
            # label = "EFI";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };

        ROOT = {
          start = "0";
          end = "100%";
          type = "8300";
          content = {
            type = "btrfs";
            extraArgs = [ "-f" ];
            # label = "ROOT";
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

        SWAP = {
          size = "8G";
          type = "8200";
          content = {
            type = "swap";
            # label = "SWAP";
          };
        };
      };
    };
  };
}
