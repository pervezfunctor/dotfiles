{ config, pkgs, modulesPath, lib, ... }:

let
  tftpRoot = "/var/lib/tftpboot";
  isoMount = "/mnt/isos";
  sambaPath = "//192.168.8.10/isos";
in {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  # _module.args.proxmox.enable = true;

  services.qemuGuest.enable = lib.mkDefault true;
  networking.hostName = "pxeserver";
  networking.interfaces.enp1s0.ipv4.addresses = [{
    address = "192.168.8.100";
    prefixLength = 24;
  }];
  networking.defaultGateway = "192.168.8.1";
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

  fileSystems."${isoMount}" = {
    device = sambaPath;
    fsType = "cifs";
    options = [ "guest" "rw" "uid=0" "gid=0" "vers=3.0" ];
  };

  services.nginx = {
    enable = true;
    virtualHosts."_" = {
      root = tftpRoot;
      extraConfig = "autoindex on;";
    };
  };

  services.dnsmasq = {
    enable = true;
    enableTFTP = true;
    enableProxyDhcp = true;
    extraConfig = ''
      interface=enp1s0
      bind-interfaces
      dhcp-range=192.168.8.0,proxy
      dhcp-match=set:ipxe,175
      dhcp-boot=tag:!ipxe,ipxe.efi
      dhcp-boot=tag:ipxe,http://192.168.8.100/ipxe/pxe-menu.ipxe
      tftp-root=${tftpRoot}
    '';
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
  networking.firewall.allowedUDPPorts = [ 69 4011 ];

  environment.systemPackages = with pkgs; [ syslinux ipxe wget ];

  systemd.tmpfiles.rules = [
    "L+ ${tftpRoot}/iso - - - - ${isoMount}"
    "L+ ${tftpRoot}/ipxe - - - - ${tftpRoot}/ipxe"
  ];

  system.activationScripts.setupPXE.text = ''
    set -e
    mkdir -p ${tftpRoot}/ipxe

    cp ${pkgs.ipxe}/ipxe.efi ${tftpRoot}/ipxe/
    cp ${pkgs.syslinux}/share/syslinux/ldlinux.c32 ${tftpRoot}/
    cp ${pkgs.syslinux}/share/syslinux/lib*.c32 ${tftpRoot}/

    cp ${./pxe-menu.ipxe} ${tftpRoot}/ipxe/pxe-menu.ipxe
  '';

  security.sudo.wheelNeedsPassword = false;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };
  programs.ssh.startAgent = true;

  users.users.me = {
    isNormalUser = true;
    description = "Your Name";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  users.users.me.openssh.authorizedKeys.keys = [''
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIcXIDK5n+AIXExMo9nt1PRGcowyvyZUPvhBGRJRGMAl pervez@fedora
  ''];
  system.stateVersion = "25.11";
}
