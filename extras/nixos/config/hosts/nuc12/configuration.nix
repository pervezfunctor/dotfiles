{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.extraModprobeConfig = "options kvm_intel nested=1";

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos";
  #   networking.wireless.enable = true;
  networking.networkmanager.enable = true;

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

  # services.xserver.enable = true;

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    konsole
  ];

  hardware.bluetooth.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  users.defaultUserShell = pkgs.zsh;
  users.users.pervez = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Pervez Iqbal";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };
  programs.zsh.enable = true;

  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "pervez";

  programs.firefox.enable = true;

  nixpkgs.config.allowUnfree = true;

  environment.sessionVariables = {
    EDITOR = "code --wait";
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    ELECTRON_ENABLE_SCALE_FACTOR = "true";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };

  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    ansible
    packer
    claude-code
    codex
    crush
    qwen-code
    gemini-cli
    copilot-cli
    curl
    devbox
    devenv
    distrobox
    eza
    fd
    fzf
    gh
    ghostty
    git
    lazydocker
    lazygit
    libguestfs
    guestfs-tools
    micro
    neovim
    nerd-fonts.jetbrains-mono
    nix-ld
    nixd
    nixfmt-rfc-style
    openssl
    pass
    doppler
    ripgrep
    starship
    stow
    tealdeer
    trash-cli
    volta
    vscode
    wget
    xorriso
    zoxide
    zsh
  ];

  services.flatpak.enable = true;
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  virtualisation.docker = {
    enable = true;

    # rootless = {
    #   enable = true;
    #   setSocketVariable = true;
    #   daemon.settings = {
    #     dns = [
    #       "1.1.1.1"
    #       "8.8.8.8"
    #     ];
    #   };
    # };
  };
  users.extraGroups.docker.members = [ "pervez" ];

  virtualisation.vmware.host.enable = true;

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu.vhostUserPackages = [ pkgs.virtiofsd ];
    };
  };
  programs.virt-manager.enable = true;
  users.extraGroups.libvirtd.members = [ "pervez" ];
  users.extraGroups.kvm.members = [ "pervez" ];

  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.openssh.enable = true;

  programs.direnv.enable = true;

  networking.nftables.enable = true;
  networking.firewall.trustedInterfaces = [ "virbr0" ];

  # virtualisation.incus.enable = true;
  # users.extraGroups.incus.members = [ "pervez" ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
