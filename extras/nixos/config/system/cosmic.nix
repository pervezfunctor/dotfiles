{ ... }:
{
  services.desktopManager.cosmic.enable = true;
  # services.displayManager.cosmic-greeter.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  security.pam.services.gdm.enableGnomeKeyring = true;
}
