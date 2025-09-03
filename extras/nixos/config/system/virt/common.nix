{ lib, ... }:
{

  # hardware.graphics = {
  #   enable = true;
  #   extraPackages = with pkgs; [
  #     virglrenderer
  #     vaapiVdpau
  #     libvdpau-va-gl
  #     # intel-vaapi-driver # Intel users
  #     amdvlk # AMD users
  #     # rocm-opencl-icd # AMD ROCm
  #   ];
  #   enable32Bit = true;
  # };

  boot.kernelModules = [
    "virtio-gpu"
    "kvm-amd"
    "vfio-pci"
  ];

  boot.extraModulePackages = [ ];
  boot.extraModprobeConfig = "options kvm_amd nested=1";
  boot.kernelParams = [
    "amd_iommu=on"
    "iommu=pt"
    "pcie_aspm=force"
    # "video=efifb:off"
    # "video=vesafb:off"
    # "video=simplefb:off"
    # "module.sig_enforce=0"  # Disable module signing enforcement
  ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv4.conf.all.forwarding" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
    "fs.inotify.max_user_instances" = 1024; # For development tools
  };
  services.rpcbind.enable = true;

  # boot.supportedFilesystems = [ "zfs" ];
  # services.zfs.autoScrub.enable = true;
  # services.zfs.autoSnapshot.enable = true;

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp2s0.useDHCP = lib.mkDefault true;

  networking.nftables.enable = true;
  networking.firewall.trustedInterfaces = [
    "incusbr0"
    "virbr0"
  ];
  networking.firewall.interfaces.incusbr0.allowedTCPPorts = [
    53
    67
  ];
  networking.firewall.interfaces.incusbr0.allowedUDPPorts = [
    53
    67
  ];

  networking.firewall.allowedTCPPorts = [
    53
    5900 # SPICE default port
    # 80 for reverse proxy
    # 443
  ];

  networking.firewall.allowedUDPPorts = [
    53
    67
  ]; # DNS + DHCP

}
