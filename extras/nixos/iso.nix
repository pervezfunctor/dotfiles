{ config, pkgs, ... }: {
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.supportedFilesystems =
    [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];

  isoImage = {
    squashfsCompression = "lz4 -b 32768";

    contents = [{
      source = ./ilm;
      target = "ilm";
      mode = "0755";
      user = "root";
      group = "root";
    }];
  };

  system.activationScripts.setupNixosHome = ''
    rm -rf /root/ilm
    cp -r ${./ilm} /root/ilm
    chown -R root:root /root/ilm
    find /root/ilm -type d -exec chmod 755 {} +
    find /root/ilm -type f -exec chmod 644 {} +
  '';

  environment = {
    shellInit = ''
      echo "🚀 Welcome to the NixOS Installer Shell"
      echo "📦 Config available at /root/ilm/config"
      echo "🛠️ Installer at /root/ilm/installer"
      echo "   Should also be available at /iso/ilm"
      echo
    '';
  };

  security.sudo.wheelNeedsPassword = false;
}
