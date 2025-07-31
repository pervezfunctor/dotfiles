{
  description = "Minimal Btrfs + Snapper Rescue ISO";

  inputs.nixpkgs.url = "nixpkgs/nixos-24.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        packages.rescue-iso = pkgs.nixosConfigurations.rescue.config.system.build.isoImage;

        nixosConfigurations.rescue = pkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            (
              { pkgs, ... }:
              {
                imports = [ "${pkgs.path}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix" ];

                networking.hostName = "rescue";
                isoImage.isoName = "rescue-btrfs.iso";

                time.timeZone = "UTC";
                i18n.defaultLocale = "en_US.UTF-8";

                users.users.root.password = "rescue";

                services.openssh.enable = true;
                services.openssh.permitRootLogin = "yes";
                services.openssh.passwordAuthentication = true;

                environment.systemPackages = with pkgs; [
                  btrfs-progs
                  snapper
                  grub-btrfs
                  inotify-tools
                  vim
                  whiptail
                  git
                  zsh
                  curl
                  wget
                  pciutils
                  usbutils
                ];

                programs.zsh.enable = true;
                programs.bash.enable = true;

                boot.supportedFilesystems = [ "btrfs" ];
                nixpkgs.config.allowUnfree = true;

                system.stateVersion = "24.05";
              }
            )
          ];
        };
      }
    );
}
