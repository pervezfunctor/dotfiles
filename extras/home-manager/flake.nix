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

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      flake-utils,
      ...
    }@inputs:
    let
      vars = import ./vars.nix;

      baseImports = [ ./core.nix ];

      mkHmModule = vars: extraImports: {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {
            inherit vars inputs;
            imports = baseImports ++ extraImports;
          };
          users.${vars.username} = import ./home.nix;
        };
      };

      mkHome =
        {
          vars,
          pkgs,
          modules ? [ ], # os modules
          imports ? [ ], # home-manager modules
        }:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit vars inputs;
            imports = baseImports ++ imports;
          };
          modules = [ ./home.nix ] ++ modules;
        };

      mkPrograms =
        { vars, pkgs, ... }@args:
        let
          modules = [ ./programs.nix ] ++ (args.modules or [ ]);
          imports = args.imports or [ ];
        in
        mkHome {
          inherit
            vars
            pkgs
            modules
            imports
            ;
        };

      varsDarwin = import ./darwin-vars.nix;
      mkDarwin =
        imports:
        import ./darwin.nix {
          inherit inputs;
          vars = varsDarwin;
          hmModule = mkHmModule varsDarwin imports;
        };

      mkWSL =
        imports:
        import ./wsl.nix {
          inherit inputs;
          inherit vars;
          hmModule = mkHmModule vars imports;
        };

    in
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-darwin" ] (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        # standalone home-manager get read USER, HOME from env.
        # vars = if system == "aarch64-darwin" then varsDarwin else varsLinux;
      in
      {
        homeConfigurations = {
          "${vars.username}" = mkHome { inherit vars pkgs; };

          shell-slim = mkHome {
            inherit vars pkgs;
            modules = [ ./shell-slim.nix ];
          };

          shell = mkHome {
            inherit vars pkgs;
            modules = [ ./shell.nix ];
          };

          sys-shell = mkHome {
            inherit vars pkgs;
            modules = [
              ./sys.nix
              ./shell.nix
            ];
          };

          shell-full = mkPrograms {
            inherit vars pkgs;
            modules = [ ./shell.nix ];
          };
        };
      }
    )
    // {
      wsl = mkWSL [ ];

      darwinConfigurations = {
        "${varsDarwin.host}" = mkDarwin [ ];
      };
    };
}
