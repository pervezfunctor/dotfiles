{ ... }:
{
  imports = [
    ./common.nix
    ./shell.nix
    ./user.nix
    ./dev.nix
    ./apps.nix
    ./virt.nix
  ];

  # @TODO: This will be your hostname, so change this
  networking.hostName = "7945hx";

  # # Enable mDNS for `hostname.local` addresses
  # services.avahi.enable = true;
  # services.avahi.nssmdns = true;
  # services.avahi.publish = {
  #   enable = true;
  #   addresses = true;
  # };
  # hardware.bluetooth.enable = true;

  system.stateVersion = "25.11";
}

# Some programs need SUID wrappers, can be configured further or are
# started in user sessions.
# programs.mtr.enable = true;
# programs.gnupg.agent = {
#   enable = true;
#   enableSSHSupport = true;
# };

# Open ports in the firewall.
# networking.firewall.allowedTCPPorts = [ ... ];
# networking.firewall.allowedUDPPorts = [ ... ];
# Or disable the firewall altogether.
# networking.firewall.enable = false;

# Enable CUPS to print documents.
# services.printing.enable = true;

# Enable touchpad support (enabled default in most desktopManager).
# services.libinput.enable = true;
