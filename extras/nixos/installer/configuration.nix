{ pkgs, vars, ... }:
{
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # enable gnome
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # or kde
  # services.displayManager.sddm.enable = true;
  # services.desktopManager.plasma6.enable = true;
  # security.pam.services.sddm.enableGnomeKeyring = true;

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  services.xserver = {
    xkb = {
      layout = "us";
      options = "caps:ctrl_modifier";
    };
  };

  nix = {
    settings = {
      auto-optimise-store = true;
      keep-build-log = true;
      keep-outputs = true;
      keep-derivations = true;

      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  nixpkgs.config.allowUnfree = true;

  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_US.UTF-8";

  networking.hostName = vars.hostName;

  users.users.${vars.userName} = {
    shell = pkgs.zsh;

    isNormalUser = true;
    createHome = true;

    extraGroups = [
      "audio"
      "input"
      "networkmanager"
      "render"
      "video"
      "wheel"
    ];

    initialPassword = vars.initialPassword;

    openssh.authorizedKeys.keys = [
      vars.sshKey
    ];

  };

  programs.bash.enable = true;
  programs.zsh.enable = true;
  programs.vscode.enable = true;
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    alejandra
    bash
    coreutils
    curl
    dialog
    gawk
    git
    gnugrep
    gnumake
    gvfs
    libsecret
    lm_sensors
    micro
    nerd-fonts.jetbrains-mono
    newt
    nixd
    nixfmt-rfc-style
    ptyxis
    rclone
    ripgrep
    rsync
    trash-cli
    unzip
    wl-clipboard
    zsh
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    vars.sshKey
  ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
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

  networking.networkmanager.enable = true;

  system.stateVersion = "25.11";
}
