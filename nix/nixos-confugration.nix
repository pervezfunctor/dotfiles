{ config, pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "25.11";

  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "nixos";
  };

  environment.systemPackages = with pkgs; [
    bat
    carapace
    curl
    delta
    emacs-nox
    eza
    fd
    fzf
    gcc
    gh
    git
    gnumake
    htop
    just
    lazygit
    luarocks
    neovim
    nixfmt-classic
    nushell
    ripgrep
    sd
    starship
    stow
    tmux
    trash-cli
    tree
    unzip
    wget
    wget
    zoxide
    zsh

  ];

  imports = [ <nixpkgs/nixos/modules/virtualisation/qemu-vm.nix> ];

  virtualisation.qemu.options = [
    "-device virtio-vga"

  ];

  services.xserver.enable = true;

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
}
