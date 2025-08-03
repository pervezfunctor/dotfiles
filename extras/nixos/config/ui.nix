{ pkgs, ... }:
{

  security.polkit.enable = true;

  services.gnome.gnome-keyring.enable = true;

  security.pam.services.login.enableGnomeKeyring = true;

  # @TODO: pick what you are using
  security.pam.services.gdm.enableGnomeKeyring = true;
  security.pam.services.swaylock.enableGnomeKeyring = true;
  # security.pam.services.sddm.enableGnomeKeyring = true; # if using SDDM

  services.dbus.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      # xdg-desktop-portal-gtk  # For GTK environments
      # xdg-desktop-portal-kde  # Uncomment if using Plasma
      xdg-desktop-portal-wlr # Uncomment if using Wayland compositor like Sway/Hyprland
    ];
    config.common.default = "*";
  };

  environment.sessionVariables = {
    EDITOR = "code --wait";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1"; # Forces Electron apps to use Wayland
    # @TODO: set it to your desktop environment
    # XDG_CURRENT_DESKTOP = "GNOME"; # or "GNOME" / "KDE" etc.
    # XDG_SESSION_TYPE = "wayland"; # or "x11"
  };

  programs.dconf.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  programs.nix-ld.enable = true;

  services.flatpak.enable = true;

  system.activationScripts.flatpak-flathub = {
    text = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  networking.networkmanager.enable = true;
  # networking.interfaces.enp1s0.useDHCP = true;
}
