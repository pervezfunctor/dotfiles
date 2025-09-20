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
          vars,
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

      mkHmModule = vars: imports: {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {
            inherit vars inputs imports;
          };
          users.${vars.username} = import ./home.nix;
        };
      };

      varsDarwin = import ./darwin-vars.nix;
      mkDarwin =
        imports:
        import ./darwin.nix {
          inherit inputs;
          vars = varsDarwin;
          hmModule = mkHmModule varsDarwin imports;
        };

      varsWSL = {
        username = "nixos";
        homeDirectory = "/home/nixos";
      };
      mkWSL =
        imports:
        import ./wsl.nix {
          inherit inputs;
          vars = varsWSL;
          hmModule = mkHmModule varsWSL imports;
        };

      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
      ];

      system =
        if builtins ? currentSystem then
          (
            if nixpkgs.lib.elem builtins.currentSystem supportedSystems then
              builtins.currentSystem
            else
              throw "Unsupported system: ${builtins.currentSystem}"
          )
        else
          throw "Could not determine current system";

      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations = {
        ${vars.username} = mkHome { inherit vars pkgs; };

        shell-slim = mkHome {
          inherit vars pkgs;
          imports = [ ./shell-slim.nix ];
        };

        shell = mkHome {
          inherit vars pkgs;
          imports = [ ./shell.nix ];
        };

        sys-shell = mkHome {
          inherit vars pkgs;
          imports = [
            ./sys.nix
            ./shell.nix
          ];
        };

        shell-full = mkHome {
          inherit vars pkgs;
          imports = [
            ./shell.nix
            ./programs.nix
          ];
        };
      };

      nixosConfigurations = {
        wsl = mkWSL [
          ./shell.nix
          ./programs.nix
        ];
      };

      darwinConfigurations = {
        "${varsDarwin.host}" = mkDarwin [ ];
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

