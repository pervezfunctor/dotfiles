{ config, pkgs, ... }:

{
  imports = [ <nixpkgs/nixos/modules/virtualisation/qemu-vm.nix> ];

  networking.hostName = "router";
  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;

  services.tailscale.enable = true;
  services.tailscale.extraUpFlags =
    [ "--advertise-routes=192.168.122.0/24" "--accept-routes" ];

  services.dnsmasq = {
    enable = true;
    settings = {
      domain-needed = true;
      bogus-priv = true;
      no-resolv = true;
      interface = "eth0";
      domain = "local";
      expand-hosts = true;
      dhcp-range = "192.168.122.100,192.168.122.200,12h";
      dhcp-authoritative = true;
    };
  };

  networking.firewall.enable = false;

  boot.kernel.sysctl."net.ipv4.ip_forward" = true;

  users.users.root.initialPassword = "nixos";

  environment.systemPackages = with pkgs; [
    bash
    iproute2
    tailscale
    dnsmasq
    vim
  ];

  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";

  system.stateVersion = "25.11";
}
