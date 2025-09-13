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
  };

  outputs = { nixpkgs, home-manager, nixos-wsl, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      vars = import ./vars.nix;
      mkHome modules = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = { inherit vars; };

        modules = mkModules;
      };
    in {
      homeConfigurations = {
        "${vars.username}" = mkHome [ ./home.nix ];
        shell-slim = mkHome [ ./home.nix ./shell-slim.nix ];
        shell = mkHome [ ./home.nix ./shell.nix ];
        sys-shell = mkHome [ ./sys.nix ./home.nix ./shell.nix ];
        programs = mkHome [ ./home.nix ./shell.nix ./programs.nix ];
      };

      wsl = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
          inherit vars;
        };
        modules = [
          {
            programs.nix-ld.enable = true;
            wsl.enable = true;
          }

          nixos-wsl.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              extraSpecialArgs = {
                inherit inputs;
                inherit vars;
              };

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
