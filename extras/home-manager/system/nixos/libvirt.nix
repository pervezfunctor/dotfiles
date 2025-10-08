{ pkgs, vars, ... }:
{
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu.vhostUserPackages = [ pkgs.virtiofsd ];
    };
  };
  programs.virt-manager.enable = true;
  users.extraGroups.libvirtd.members = [ vars.username ];
  users.extraGroups.kvm.members = [ vars.username ];

  environment.systemPackages = with pkgs; [
    guestfs-tools
    libguestfs
    virt-manager
    xorriso
  ];
}
