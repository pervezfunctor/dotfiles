{ pkgs, vars, ... }:
{
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

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
  programs.zsh.enable = true;
  programs.bash.enable = true;

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
    libsecret
    lm_sensors
    micro
    newt
    nixd
    nixfmt-rfc-style
    unzip
    zsh
  ];

  users.users.root.openssh.authorizedKeys.keys = vars.sshKey;
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  system.stateVersion = "25.11";
}
