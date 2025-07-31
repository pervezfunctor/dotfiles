{
  description = "Unified NixOS VM and ISO flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations = {
        iso = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            ./iso.nix
          ];
        };

        vm = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./ilm/config/shell.nix
            ./vm.nix
          ];
        };
      };

      packages.${system} = {
        iso = self.nixosConfigurations.iso.config.system.build.isoImage;
        vm = self.nixosConfigurations.vm.config.system.build.vm;
      };

    };
}
