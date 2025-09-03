{ pkgs, ... }:
{

  security.polkit.enable = true;

  services.gnome.gnome-keyring.enable = true;

  security.pam.services.login.enableGnomeKeyring = true;

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
    ELECTRON_ENABLE_SCALE_FACTOR = "true";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    XDG_SESSION_TYPE = "wayland";
    # GDK_SCALE = "";
    # GDK_DPI_SCALE = "";
  };

  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-emoji
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji

      font-awesome
    ];

    fontconfig = {
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font" ];
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  programs.dconf.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  programs.nix-ld.enable = true;

  services.flatpak.enable = true;

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  environment.systemPackages = with pkgs; [
    wl-clipboard
    gvfs
  ];

  networking.networkmanager.enable = true;
}
