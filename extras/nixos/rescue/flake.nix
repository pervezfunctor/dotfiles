{
  description = "Minimal Btrfs + Snapper Rescue ISO";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.rescue = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          (
            { pkgs, ... }:
            {
              nix.settings.experimental-features = [
                "nix-command"
                "flakes"
              ];

              networking.hostName = "rescue";
              image.fileName = "rescue-btrfs.iso";

              time.timeZone = "UTC";
              i18n.defaultLocale = "en_US.UTF-8";

              users.users.root.password = "rescue";

              services.openssh.enable = true;
              services.openssh.settings.PermitRootLogin = "yes";
              services.openssh.settings.PasswordAuthentication = true;

              environment.systemPackages = with pkgs; [
                btrfs-progs
                snapper
                inotify-tools
                vim
                newt
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

              system.stateVersion = "25.11";
            }
          )
        ];
      };

      packages.${system}.rescue-iso =
        (nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            (
              { pkgs, ... }:
              {
                nix.settings.experimental-features = [
                  "nix-command"
                  "flakes"
                ];

                networking.hostName = "rescue";
                image.fileName = "rescue-btrfs.iso";

                time.timeZone = "UTC";
                i18n.defaultLocale = "en_US.UTF-8";

                users.users.root.password = "rescue";

                services.openssh.enable = true;
                services.openssh.settings.PermitRootLogin = "yes";
                services.openssh.settings.PasswordAuthentication = true;

                environment.systemPackages = with pkgs; [
                  btrfs-progs
                  snapper
                  inotify-tools
                  vim
                  newt
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

                system.stateVersion = "25.11";
              }
            )
          ];
        }).config.system.build.isoImage;
    };
}
