{ pkgs, ... }:
{
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  security.pam.services.gdm.enableGnomeKeyring = true;

  programs.dconf.enable = true;
  programs.gnome-terminal.enable = true;

  environment.systemPackages = with pkgs; [
    gnome-software
    nautilus
    refine
    gearlever
    warehouse
  ];

  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "GNOME";
  };
  # xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # services.gnome.core-apps.enable = false;

  # services.accounts-daemon.enable = true;
  # services.dleyna-renderer.enable = mkDefault true;
  # services.dleyna-server.enable = mkDefault true;
  # services.power-profiles-daemon.enable = mkDefault true;
  # services.gnome.at-spi2-core.enable = true;
  # services.gnome.evolution-data-server.enable = true;
  # services.gnome.gnome-keyring.enable = true;
  # services.gnome.gnome-online-accounts.enable = mkDefault true;
  # services.gnome.gnome-online-miners.enable = true;
  # services.gnome.tracker-miners.enable = mkDefault true;
  # services.gnome.tracker.enable = mkDefault true;
  # services.hardware.bolt.enable = mkDefault true;
  # services.udisks2.enable = true;
  # services.upower.enable = config.powerManagement.enable;
  # services.xserver.libinput.enable = mkDefault true;
  # networking.networkmanager.enable = mkDefault true;
  # services.colord.enable = mkDefault true;
  # services.gnome.glib-networking.enable = true;
  # services.gnome.gnome-browser-connector.enable = mkDefault true;
  # services.gnome.gnome-initial-setup.enable = mkDefault true;
  # services.gnome.gnome-remote-desktop.enable = mkDefault true;
  # services.gnome.gnome-settings-daemon.enable = true;
  # services.gnome.gnome-user-share.enable = mkDefault true;
  # services.gnome.rygel.enable = mkDefault true;
  # services.gvfs.enable = true;
  # services.system-config-printer.enable = (mkIf config.services.printing.enable (mkDefault true));
  # services.avahi.enable = mkDefault true;
  # services.geoclue2.enable = mkDefault true;

  # environment.gnome.excludePackages = with pkgs; [
  #   gnome-photos
  #   gnome-tour
  #   gnome-music
  #   gedit # text editor
  #   geary # email reader
  #   gnome-characters
  #   tali # poker game
  #   iagno # go game
  #   hitori # sudoku game
  #   atomix # puzzle game
  #   yelp # Help view
  #   gnome-contacts
  #   gnome-initial-setup
  # ];

  # services.gnome.core-apps.enable = false;
  # services.gnome.core-developer-tools.enable = false;
  # services.gnome.games.enable = false;
  # environment.systemPackages = with pkgs; [ gnome-console ];
  # environment.gnome.excludePackages = with pkgs; [ gnome-tour gnome-user-docs ];
  # environment.systemPackages = with pkgs; [
  #   gnomeExtensions.blur-my-shell
  #   gnomeExtensions.just-perfection
  #   gnomeExtensions.arc-menu
  # ];

  # dconf = {
  #   enable = true;
  #   settings = {
  #     "org/gnome/shell" = {
  #       # disable-user-extensions = true; # Optionally disable user extensions entirely
  #       enabled-extensions = [
  #         # Put UUIDs of extensions that you want to enable here.
  #         # If the extension you want to enable is packaged in nixpkgs,
  #         # you can easily get its UUID by accessing its extensionUuid
  #         # field (look at the following example).
  #         pkgs.gnomeExtensions.gsconnect.extensionUuid

  #         # Alternatively, you can manually pass UUID as a string.
  #         "blur-my-shell@aunetx"
  #         # ...
  #       ];
  #     };

  #     # Configure individual extensions
  #     "org/gnome/shell/extensions/blur-my-shell" = {
  #       brightness = 0.75;
  #       noise-amount = 0;
  #     };
  #   };
  # };
  # qt = {
  #   enable = true;
  #   platformTheme = "gnome";
  #   style = "adwaita-dark";
  # };

  # environment.systemPackages = [ pkgs.gnomeExtensions.appindicator  ];
  # services.udev.packages = [ pkgs.gnome-settings-daemon ];
}
