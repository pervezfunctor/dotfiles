{
  description = "ILM home-manager flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nixos-wsl,
      flake-utils,
      ...
    }@inputs:
    let
      vars = import ./vars.nix;

      mkHome =
        pkgs: modules:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit vars; };
          modules = [ ./home.nix ] ++ modules;
        };

      mkPrograms = pkgs: modules: mkHome pkgs [ ./programs.nix ] ++ modules;
    in
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-darwin" ] (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        legacyPackages = {
          homeConfigurations = {
            "${vars.username}" = mkHome pkgs [ ];
            shell-slim = mkHome pkgs [ ./shell-slim.nix ];
            shell = mkHome pkgs [ ./shell.nix ];
            sys-shell = mkHome pkgs [
              ./sys.nix
              ./shell.nix
            ];
            shell-full = mkPrograms pkgs [ ./shell.nix ];
          };
        };

        formatter = pkgs.nixpkgs-fmt;
      }
    )
    // {
      wsl = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs vars; };
        modules = [
          {
            programs.nix-ld.enable = true;
            wsl.enable = true;
          }
          nixos-wsl.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              extraSpecialArgs = { inherit inputs vars; };
              useUserPackages = true;
              useGlobalPkgs = true;
              backupFileExtension = "backup";
              users.nixos = import ./home.nix;
            };
          }
        ];
      };
    };
}
