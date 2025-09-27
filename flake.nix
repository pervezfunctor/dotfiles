{
  description = "Devcontainer environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          eza
          fzf
          gh
          micro
          shellcheck
          shfmt
          stow
          zoxide
        ];
      };

      shellHooks = {
        default = "echo 'Welcome to the devcontainer!'";
      };
    };
}
