{
  description = "Sensible modern flake for nix develop with formatter and direnv";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      flake-parts.inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      flake-parts,
      treefmt-nix,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      imports = [
        treefmt-nix.flakeModule
      ];

      perSystem =
        {
          pkgs,
          lib,
          system,
          ...
        }:
        let
          isDarwin = pkgs.stdenv.isDarwin;
        in
        {
          devShells.default = pkgs.mkShell {
            packages =
              with pkgs;
              [
                git
                jq
                curl

                (python314.withPackages (ps: [
                  ps.pip
                  ps.pipx
                  ps.uv
                  ps.virtualenv
                ]))
              ]
              ++ lib.optionals isDarwin [
                pkgs.apple-sdk.frameworks.Security
              ];

            shellHook = ''
              export LANG=C.UTF-8
              echo "Entering dev shell on ${system}"
            '';
          };

          # nix fmt via treefmt-nix (adds formatter.<system> automatically)
          treefmt = {
            programs = {
              alejandra.enable = true; # Nix formatter
              shfmt.enable = true; # Shell
              black.enable = true; # Python
            };
            # treefmt-nix also wires a flake check and formatter by default
          };
        };
    };
}
