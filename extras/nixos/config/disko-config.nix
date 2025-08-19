{ vars, ... }:

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
    device = vars.diskoMainDisk;
    content = {
      type = "gpt";
      partitions = {
        EFI = {
          size = "1G";
          type = "ef00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        SWAP = {
          size = vars.diskoSwapSize or "8G"; # fallback if not defined
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
            subvolumes = {
              "@" = {
                mountpoint = "/";
                mountOptions = btrfsOpts ++ [ "subvol=@" ];
              };
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
              "@cache" = {
                mountpoint = "/var/cache";
                mountOptions = btrfsOpts ++ [ "subvol=@cache" ];
              };
              "@tmp" = {
                mountpoint = "/tmp";
                mountOptions = btrfsOpts ++ [ "subvol=@tmp" ];
              };
              "@srv" = {
                mountpoint = "/srv";
                mountOptions = btrfsOpts ++ [ "subvol=@srv" ];
              };
              "@opt" = {
                mountpoint = "/opt";
                mountOptions = btrfsOpts ++ [ "subvol=@opt" ];
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
