{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  # networking.wireless.enable = true; # wireless support via wpa_supplicant.

  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  environment.sessionVariables = {
    EDITOR = "code --wait";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
  };

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  programs.dconf.profiles.user.databases = [
    {
      lockAll = true; # prevents overriding
      settings = {
        "org/gnome/desktop/interface" = {
          accent-color = "green";
        };

        "org/gnome/mutter" = {
          experimental-features = [ "scale-monitor-framebuffer" ];
        };

        "org/gnome/desktop/input-sources" = {
          xkb-options = [ "ctrl:nocaps" ];
        };
      };
    }
  ];

  environment.shells = with pkgs; [ zsh ];

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.pervez = {
    isNormalUser = true;
    description = "Pervez Iqbal";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
  };
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "pervez";
  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  programs.firefox.enable = true;

  programs.zsh.enable = true;
  programs.starship.enable = true;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    nixfmt-rfc-style
    curl
    devbox
    devenv
    direnv
    eza
    fzf
    gh
    git
    gvfs
    neovim
    nerd-fonts.jetbrains-mono
    nixd
    ptyxis
    ripgrep
    stow
    vscode
    wget
    wl-clipboard
    zoxide
  ];

  virtualisation.docker.enable = true;

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  services.flatpak.enable = true;
  programs.nix-ld.enable = true;

  services.openssh.enable = true;
  networking.firewall.enable = true;

  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 5d";
      persistent = true;
    };

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

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  system.stateVersion = "25.05";
}
