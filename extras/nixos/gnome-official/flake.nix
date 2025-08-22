{
  description = "Minimal NixOS configuration using flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05"; # or use `nixos-unstable`
  };

  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
        ];
      };
    };
  };
}
