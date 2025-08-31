{ vars, ... }:
{
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ vars.username ];
  virtualisation.virtualbox.host.enableExtensionPack = true;
  virtualisation.virtualbox.host.enableWebService = true;
  virtualisation.virtualbox.host.enableKvm = true;
  # for kvm, this should be disabled
  virtualisation.virtualbox.host.addNetworkInterface = false;

}
