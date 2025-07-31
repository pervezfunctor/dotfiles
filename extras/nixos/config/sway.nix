{ pkgs, ... }:
{
  services.displayManager.gdm.enable = true;
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;

    extraSessionCommands = ''
      if ! pgrep -x gnome-keyring-daemon > /dev/null; then
        eval "$(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)"
        export SSH_AUTH_SOCK
      fi
    '';

    extraPackages = with pkgs; [
      swaylock
      libsecret
      rofi-wayland
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
