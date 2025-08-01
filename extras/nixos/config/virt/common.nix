{ pkgs, ... }:
{
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      virglrenderer
      vaapiVdpau
      libvdpau-va-gl
      # intel-vaapi-driver # Intel users
      amdvlk # AMD users
      # rocm-opencl-icd # AMD ROCm
    ];
    enable32Bit = true;
  };

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

  # networking.nftables.enable = true;
  # networking.firewall.trustedInterfaces = [ "incusbr0" ];
  # networking.firewall.interfaces.incusbr0.allowedTCPPorts = [
  #   53
  #   67
  # ];
  # networking.firewall.interfaces.incusbr0.allowedUDPPorts = [
  #   53
  #   67
  # ];

  networking.firewall.trustedInterfaces = [ "virbr0" ]; # Allow all traffic on bridge
  networking.firewall.allowedTCPPorts = [
    53
    5900
  ]; # SPICE default port
  networking.firewall.allowedUDPPorts = [
    53
    67
  ]; # DNS + DHCP

}
