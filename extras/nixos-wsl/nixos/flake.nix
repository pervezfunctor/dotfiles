{
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

  outputs =
    {
      nixpkgs,
      nixos-wsl,
      home-manager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      homeConfigurations."nixos" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
      };

      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
          };
          modules = [
            {
              programs.nix-ld.enable = true;
              wsl.enable = true;
              wsl.defaultUser = "nixos";
              users.users."nixos".shell = pkgs.zsh;
              programs.zsh.enable = true;
              system.stateVersion = "25.11";
              nixpkgs.config.allowUnfree = true;
            }

            nixos-wsl.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                extraSpecialArgs = {
                  inherit inputs;
                  # inherit vars;
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
    };
}
