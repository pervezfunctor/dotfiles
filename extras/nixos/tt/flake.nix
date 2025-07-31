{
  description = "tt-based flake template generator";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        bootstrap = import ./bootstrap.nix { inherit pkgs; };
      in {
        packages.bootstrap = bootstrap;
        apps.bootstrap = flake-utils.lib.mkApp { drv = bootstrap; };
        defaultPackage = bootstrap;
        defaultApp = flake-utils.lib.mkApp { drv = bootstrap; };
      });
}
