{ ... }:
{
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "me" ];
  virtualisation.virtualbox.host.enableExtensionPack = true;
}
