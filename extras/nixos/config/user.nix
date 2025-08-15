{ pkgs, ... }:
{
  users.users.me = {
    shell = pkgs.zsh;

    isNormalUser = true;
    createHome = true;

    extraGroups = [
      "audio"
      "cockpit-ws"
      "docker"
      "incus-admin"
      "incus"
      "input"
      "qemu-libvirtd"
      "kvm"
      "libvirtd"
      "networkmanager"
      "render"
      "video"
      "wheel"
    ];

    initialPassword = "nixos";

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIcXIDK5n+AIXExMo9nt1PRGcowyvyZUPvhBGRJRGMAl me@fedora"
    ];

  };
}
