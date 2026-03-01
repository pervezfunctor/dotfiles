{ pkgs, vars, ... }:
let
  shellInit = ''
    if [[ -d "$HOME/.ilm" ]]; then
      source "$HOME/.ilm/share/shellrc"
    fi
  '';
  shellAliases = {
    nrs = "update-os";
  };
in
{
  # hardware.graphics.enable = true;
  # services.smartd.enable = true;
  hardware.enableRedistributableFirmware = true;
  hardware.bluetooth.enable = true;

  nixpkgs.config.allowUnfree = true;

  environment.sessionVariables = {
    XCURSOR_SIZE = "32";
    XCURSOR_THEME = "Bibata-Modern-Ice";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    QT_QPA_PLATFORM = "wayland";
    # QT_QPA_PLATFORMTHEME = "gtk3";
    # QT_QPA_PLATFORMTHEME_QT6 = "gtk3";
  };

  services.power-profiles-daemon.enable = true; # or services.tuned.enable for laptop
  services.upower.enable = true;
  services.dbus.enable = true;
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.udisks2.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true; # thumbnailer for nautilus/thunar
  programs.thunar.enable = true;
  programs.xfconf.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 2d";
      persistent = true;
    };
  };

  programs.nix-ld.enable = true;

  services.flatpak.enable = true;

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    inherit shellInit shellAliases;
  };
  programs.fish.enable = true;
  programs.bash = {
    enable = true;
    completion.enable = true;
    inherit shellInit shellAliases;
  };

  programs.starship = {
    enable = true;
    interactiveOnly = true;
    transientPrompt.enable = true;
  };

  fonts = {
    packages = with pkgs; [
      fira-code
      font-awesome
      inter
      inter-nerdfont
      nerd-fonts.jetbrains-mono
      nerd-fonts.monaspace
      noto-fonts
      noto-fonts-color-emoji
    ];
    fontconfig = {
      enable = true;
      # defaultFonts = {
      #   serif = [ "Noto Serif" ];
      #   sansSerif = [
      #     "Inter"
      #     "Noto Sans"
      #   ];
      # };
    };
  };

  users.extraGroups.video.members = [ vars.username ];
  programs.neovim.enable = true;

  environment.systemPackages = with pkgs; [
    dbus
    udisks2
    udiskie
    wl-clipboard
    libxcb
    libxcb-wm
    adwaita-fonts
    adwaita-icon-theme
  ];
}
