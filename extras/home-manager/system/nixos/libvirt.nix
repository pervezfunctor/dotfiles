{ pkgs, ... }:
{
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu.vhostUserPackages = [ pkgs.virtiofsd ];
    };
  };
  programs.virt-manager.enable = true;
  users.extraGroups.libvirtd.members = [ "pervez" ];
  users.extraGroups.kvm.members = [ "pervez" ];

  environment.systemPackages = with pkgs; [
    guestfs-tools
    libguestfs
    virt-manager
    xorriso
  ];
}
