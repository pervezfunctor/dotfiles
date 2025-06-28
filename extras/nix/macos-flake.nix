{
  description = "My macOS Nix dev shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            direnv
            nixd
            statix
            nixpkgs-fmt
          ];

          shellHook = ''
            echo "💻 Welcome to your Nix dev environment!"
          '';
        };
      });
}
