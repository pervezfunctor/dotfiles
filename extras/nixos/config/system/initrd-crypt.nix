{ config, ... }:
{
  boot.kernelParams = [ "ip=dhcp" ];

  boot.initrd = {
    # TODO: Might have to update this based on your hardware
    #  Use generate-nixos-hardware-config to get the correct modules
    availableKernelModules = [
      "virtio_pci"
      "virtio_net"
      "virtio_scsi"
      "ahci"
      "sd_mod"
    ];
    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 2222;
        authorizedKeys = config.users.users.root.openssh.authorizedKeys.keys;
        hostKeys = [ "/etc/ssh/ssh_host_ed25519_key" ];
        shell = "/bin/cryptsetup-askpass";
      };
    };
  };
}
