{ pkgs, ... }:
with pkgs;
[
  acpi
  ghostscript_headless
  gnupg
  nixos-generators
  pciutils
  pre-commit
  rsync
  sops
  ssh-to-age
  swayosd
  syncthingtray-minimal
  usbutils
  yubico-pam
  yubico-piv-tool
  yubikey-manager
  yubikey-personalization
  yubikey-touch-detector
  yubioath-flutter
  # wireguard-tools
  # sbctl
  # cfssl
  # zig
  # zls
]
