{
  description = "ILM NixOS configuration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";
    flake-parts.url = "github:hercules-ci/flake-parts";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      agenix,
      stylix,
      home-manager,
      quadlet-nix,
      disko,
      # nixvim,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      vars = import ./vars.nix { inherit pkgs; };

      commonModules = [
        ./configuration.nix
        stylix.nixosModules.stylix
        quadlet-nix.nixosModules.quadlet
        # nixvim.nixosModules.nixvim
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
            users.${vars.userName} = import ./home/home.nix;
          };
        }
      ];

      uiModules = commonModules ++ [
        ./ui.nix
      ];

      mkNixosSystem =
        modules:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
            inherit vars;
          };
          modules = modules;
        };

      mkUiSystem = extraModules: mkNixosSystem (uiModules ++ extraModules);

      mkBareSystem =
        extraModules:
        mkNixosSystem (
          uiModules
          ++ extraModules
          ++ [
            agenix.nixosModules.default
          ]
        );

      mkVmSystem =
        extraModules:
        mkNixosSystem (
          uiModules
          ++ extraModules
          ++ [
            ./vm.nix
            ../ssh.nix
          ]
        );

      mkAnywhereSystem =
        extraModules:
        mkBareSystem (
          extraModules
          ++ [
            disko.nixosModules.disko
          ]
        );

    in
    {
      homeConfigurations = {
        ${vars.userName} = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = { inherit inputs vars; };
          modules = [
            # nixvim.homeManagerModules.nixvim
            ./home/home.nix
          ];
        };
      };

      nixosConfigurations = {
        server = mkNixosSystem (commonModules ++ [ ./ssh.nix ]);

        gnome = mkUiSystem [ ./gnome.nix ];
        gnome-vm = mkVmSystem [ ./gnome.nix ];

        kde = mkUiSystem [ ./kde.nix ];
        kde-vm = mkVmSystem [ ./kde.nix ];

        sway = mkUiSystem [ ./sway.nix ];
        sway-vm = mkVmSystem [ ./sway.nix ];

        "${vars.hostName}" = mkAnywhereSystem [
          ./disko-config.nix
          ./gnome.nix
          ./ssh.nix
          ./hosts/${vars.hostName}/hardware-configuration.nix
        ];

        um580 = mkBareSystem [
          ./hosts/um580/hardware-configuration.nix
          ./hosts/um580/fs.nix
          ./sway.nix
        ];

        "7945hx" = mkBareSystem [
          ./hosts/7945hx/hardware-configuration.nix
          ./gnome.nix
          ./vm.nix
        ];
      };
    };
}
