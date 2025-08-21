{
  description = "Minimal NixOS configuration using flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05"; # or use `nixos-unstable`
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in {
        packages.hello = pkgs.hello;
      }
    ) // {
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
