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

      # validatedUsername =
      #   if vars.username == "" then
      #     throw "ERROR: Username is empty! Please ensure USER environment variable is set."
      #   else
      #     builtins.trace "DEBUG: Username is '${vars.username}'" vars.username;

      mkHome =
        {
          pkgs,
          imports ? [ ],
        }:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
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
        imports:
        import ./darwin.nix {
          inherit inputs vars;

          hmModule = mkHmModule imports;
        };

      mkWSL =
        imports: osImports:
        import ./wsl.nix {
          inherit inputs osImports vars;
          hmModule = mkHmModule imports;
        };

      mkNixos =
        imports: osImports:
        import ./nixos.nix {
          inherit
            inputs
            osImports
            vars
            pkgs
            ;

          hmModule = mkHmModule imports;
        };

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

      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations = {
        ${vars.username} = mkHome {
          inherit vars pkgs;
          imports = [ ./home/core.nix ];
        };

        shell-slim = mkHome {
          inherit vars pkgs;
          imports = [
            ./home/core.nix
            ./home/shell-slim.nix
          ];
        };

        shell = mkHome {
          inherit vars pkgs;
          imports = [
            ./home/core.nix
            ./home/shell-slim.nix
            ./home/shell.nix
          ];
        };

        shell-full = mkHome {
          inherit vars pkgs;
          imports = [ ./home ];
        };
      };

      nixosConfigurations = {
        wsl = mkWSL [ ./home/core.nix ] [ ];

        nixos =
          mkNixos
            [
              ./home/core.nix
              ./home/shell-slim.nix
              ./home/shell.nix
            ]
            [ ];
      };

      darwinConfigurations = {
        "${vars.host}" = mkDarwin [
          ./home/core.nix
        ];
      };

      formatter = nixpkgs.legacyPackages.${system}.alejandra;

      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          home-manager
          git
        ];
        shellHook = ''
          echo "Home Manager development environment"
        '';
      };
    };
}
