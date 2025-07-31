{ pkgs, ... }:
{
  virtualisation.docker.enable = true;

  virtualisation = {
    # libvirtd = {
    #   enable = true;
    #   qemu = {
    #     package = pkgs.qemu_kvm;
    #     runAsRoot = true;
    #     swtpm.enable = true;
    #     ovmf = {
    #       enable = true;
    #       packages = [
    #         (pkgs.OVMF.override {
    #           secureBoot = true;
    #           tpmSupport = true;
    #         }).fd
    #       ];
    #     };
    #   };

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

    incus.enable = true;
  };

  networking.nftables.enable = true;
  # networking.firewall.trustedInterfaces = [ "incusbr0" ];
  networking.firewall.interfaces.incusbr0.allowedTCPPorts = [
    53
    67
  ];
  networking.firewall.interfaces.incusbr0.allowedUDPPorts = [
    53
    67
  ];

  users.users.me.extraGroups = [
    "kvm"
    "libvirt"
    "incus"
    "incus-admin"
    "docker"
  ];

  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    libvirt
    qemu
    dnsmasq
    docker-compose

    openssl
    xorriso
    cdrkit

  ];
}
