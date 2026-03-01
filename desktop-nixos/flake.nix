{
  description = "NixOS flake configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    caelestia = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mango = {
      url = "github:DreamMaoMao/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      mango,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      vars = import ./vars.nix;

      mangoModules = import ./desktop/mango.nix { inherit inputs pkgs; };
      swayModules = import ./desktop/sway.nix { inherit inputs pkgs; };
      gnomeModules = import ./desktop/gnome.nix { inherit inputs pkgs; };
      niriModules = import ./desktop/niri.nix { inherit inputs pkgs; };
      hyprlandModules = import ./desktop/hyprland.nix { inherit inputs pkgs; };

      baseOSModules = [
        ./core/core.nix
        ./core/virt.nix
        ./desktop/portal.nix
        ./desktop/apps.nix
        ./desktop/wm.nix

        home-manager.nixosModules.home-manager
        ./core/homeModule.nix
      ];
      mkOS =
        osModules: homeImports:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs vars homeImports; };

          modules = baseOSModules ++ osModules;
        };

      mkHome =
        homeImports:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [
            ./core/home.nix
            ./home/wm.nix
            ./home/dev.nix
            ./home/gtk.nix
          ]
          ++ homeImports;
          extraSpecialArgs = { inherit inputs vars; };
        };

      allOSModules = [
        mango.nixosModules.mango
        mangoModules.nixosModule
        swayModules.nixosModule
        niriModules.nixosModule
        hyprlandModules.nixosModule
      ];

      allHomeModules = [
        mangoModules.homeModule
        swayModules.homeModule
        niriModules.homeModule
        hyprlandModules.homeModule
        gnomeModules.homeModule
        ./home/gtk.nix
        ./home/gnome.nix
        ./home/caelestia.nix
        ./home/dms.nix
        ./home/noctalia.nix
      ];

      mkMin = config: mkOS [ config ] [ ];
      mkNoHm = config: mkOS ([ config ] ++ allOSModules) [ ];
      mkSway =
        config: mkOS [ config swayModules.nixosModule ] [ swayModules.homeModule ./home/noctalia.nix ];
      mkNiri = config: mkOS [ config niriModules.nixosModule ] [ niriModules.homeModule ./home/dms.nix ];
      mkHyprland =
        config:
        mkOS [ config hyprlandModules.nixosModule ] [ hyprlandModules.homeModule ./home/caelestia.nix ];
      mkAll = config: mkOS ([ config ] ++ allOSModules) allHomeModules;
      mkGnome = config: mkOS [ config gnomeModules.nixosModule ] [ gnomeModules.homeModule ];
      mkMango =
        config:
        mkOS
          [
            config
            mango.nixosModules.mango
            mangoModules.nixosModule
          ]
          [ mangoModules.homeModule ./home/noctalia.nix ];
    in
    {
      nixosConfigurations = {
        nixos = mkMin ./hosts/nixos/configuration.nix;

        bd795 = mkAll ./hosts/bd795/configuration.nix;

        niri-nuc-vm =
          mkOS
            [
              niriModules.nixosModule
              ./hosts/niri-nuc-vm/configuration.nix
            ]
            [
              niriModules.homeModule
              ./home/dms.nix
            ];

        mango-nuc-vm =
          mkOS
            [
              mango.nixosModules.mango
              mangoModules.nixosModule
              ./hosts/mango-nuc-vm/configuration.nix
            ]
            [
              mangoModules.homeModule
              ./home/noctalia.nix
            ];

        # only for testing, you need to copy your system configuration
        # for eg: cp  /etc/nixos/* ./nixos/
        sway = mkSway ./hosts/nixos/configuration.nix;
        niri = mkNiri ./hosts/nixos/configuration.nix;
        hyprland = mkHyprland ./hosts/nixos/configuration.nix;
        mango = mkMango ./hosts/nixos/configuration.nix;
        gnome = mkGnome ./hosts/nixos/configuration.nix;
        noHm = mkNoHm ./hosts/nixos/configuration.nix;
        all = mkAll ./hosts/nixos/configuration.nix;
      };

      packages.${system} = nixpkgs.lib.mapAttrs' (n: v: {
        name = "${n}-vm";
        value = v.config.system.build.vm;
      }) self.nixosConfigurations;

      homeConfigurations = {
        noctalia = mkHome [ ./home/noctalia.nix ];
        dms = mkHome [ ./home/dms.nix ];
        caelestia = mkHome [ ./home/caelestia.nix ];

        dmsOnly = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [
            ./core/home.nix
            ./home/dms.nix
            ./home/min-packages.nix
          ];
          extraSpecialArgs = { inherit inputs vars; };
        };
      };
    };
}
