{ pkgs, ... }:
{
  services.displayManager.gdm.enable = true;
  security.pam.services.swaylock.enableGnomeKeyring = true;
  # xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-kde ];

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;

    # extraSessionCommands = ''
    #   if ! pgrep -x gnome-keyring-daemon > /dev/null; then
    #     eval "$(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)"
    #     export SSH_AUTH_SOCK
    #   fi
    # '';

    extraPackages = with pkgs; [
      swaylock
      mako
      foot

      nwg-bar
      nwg-clipman
      nwg-displays
      nwg-look
      swayidle
      libsecret
      rofi
      swaynotificationcenter
      networkmanagerapplet
      wl-clipboard
      wf-recorder
      grim
      slurp
      wlogout
    ];
  };

  programs.waybar.enable = true;
}
