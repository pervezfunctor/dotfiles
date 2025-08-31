{ pkgs, vars, ... }:
{
  users.users.${vars.username} = {
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
      # "libvirt-qemu"
      "kvm"
      "libvirtd"
      "networkmanager"
      "render"
      "video"
      "wheel"
    ];

    initialPassword = vars.initialPassword;

    openssh.authorizedKeys.keys = [
      vars.sshKey
    ];

  };
}
