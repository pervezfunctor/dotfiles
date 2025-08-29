{ ... }:
{
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  # virtualisation.virtualbox.guest.enable = true;
  # virtualisation.virtualbox.guest.clipboard = "Bidirectional";
  # virtualisation.virtualbox.guest.dragAndDrop = "Bidirectional";
  # virtualisation.virtualbox.guest.seamless = true;

  # services.xserver.drivers = [ "vmware" ];
  # virtualisation.vmware.guest.enable = true;
}
