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

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      vars = import ./vars.nix;

      supportedSystems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      system =
        if builtins ? currentSystem then
          (
            if nixpkgs.lib.elem builtins.currentSystem supportedSystems then
              builtins.currentSystem
            else
              throw "ERROR: Unsupported system '${builtins.currentSystem}'. Supported systems are: ${builtins.concatStringsSep ", " supportedSystems}"
          )
        else
          "x86_64-linux";

      mkHome =
        {
          imports ? [ ],
        }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = {
            inherit vars inputs imports;
          };
          modules = [ ./home.nix ];
        };

      mkHmModule = imports: {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {
            inherit vars inputs imports;
          };
          users.${vars.username} = import ./home.nix;
        };
      };

      mkDarwin =
        {
          homeImports,
          osImports ? [ ],
        }:
        import ./darwin.nix {
          inherit inputs vars osImports;

          hmModule = mkHmModule homeImports;
        };

      mkWSL =
        {
          homeImports,
          osImports ? [ ],
        }:
        import ./wsl.nix {
          inherit inputs osImports vars;
          hmModule = mkHmModule homeImports;
        };

      mkNixos =
        {
          homeImports,
          osImports ? [ ],
        }:
        import ./nixos.nix {
          inherit inputs osImports vars;
          hmModule = mkHmModule homeImports;
        };
    in
    {
      homeConfigurations = {
        ${vars.username} = mkHome {
          imports = [ ./home/core.nix ];
        };

        shell-slim = mkHome {
          imports = [
            ./home/core.nix
            ./home/shell-slim.nix
          ];
        };

        shell = mkHome {
          imports = [
            ./home/core.nix
            ./home/shell-slim.nix
            ./home/shell.nix
          ];
        };

        shell-full = mkHome {
          imports = [
            ./home/core.nix
            ./home/shell-slim.nix
            ./home/shell.nix
            ./home/programs.nix
          ];
        };

        all = mkHome {
          imports = [ ./home ];
        };
      };

      nixosConfigurations = {
        wsl = mkWSL { homeImports = [ ./home/core.nix ]; };

        "${vars.hostname}" = mkNixos { homeImports = [ ./home ]; };
      };

      darwinConfigurations = {
        "${vars.hostname}" = mkDarwin {
          homeImports = [
            ./home/core.nix
          ];
        };
      };

      # formatter = nixpkgs.legacyPackages.${system}.alejandra;

      # devShells.default = pkgs.mkShell {
      #   buildInputs = with pkgs; [
      #     home-manager
      #     git
      #   ];
      #   shellHook = ''
      #     echo "Home Manager development environment"
      #   '';
      # };
    };
}
