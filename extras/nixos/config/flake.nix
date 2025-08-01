{
  description = "ILM NixOS configuration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    microvm = {
      url = "github:microvm-nix/microvm.nix";
    };

    home-manager = {
      # Follow corresponding `release` branch from Home Manager
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      agenix,
      stylix,
      home-manager,
      microvm,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      commonModules = [
        ./configuration.nix
        stylix.nixosModules.stylix
        home-manager.nixosModules.home-manager
        # microvm.
        {
          home-manager = {
            extraSpecialArgs = { inherit inputs; };
            users.me = import ./home/home.nix;
          };
        }
      ];

      uiModules = commonModules ++ [
        ./ui.nix
      ];
    in
    {
      homeConfigurations = {
        "me" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs; };
          modules = [ ./home/home.nix ];
        };
      };

      nixosConfigurations = {
        server = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };

          modules = commonModules ++ [
            ./ssh.nix
          ];
        };

        gnome = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };

          modules = uiModules ++ [
            ./gnome.nix
          ];
        };

        kde = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };

          modules = uiModules ++ [
            ./kde.nix
          ];
        };

        gnome-vm = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };

          modules = uiModules ++ [
            ./gnome.nix
            ./vm.nix
          ];
        };

        kde-vm = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };

          modules = uiModules ++ [
            ./kde.nix
            ./vm.nix
          ];
        };

        sway = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };

          modules = uiModules ++ [
            ./sway.nix
          ];
        };

        sway-vm = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };

          modules = uiModules ++ [
            ./sway.nix
            ./vm.nix
          ];
        };

        um580 = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };

          modules = uiModules ++ [
            ./hosts/um580/hardware-configuration.nix
            ./hosts/um580/fs.nix
            ./sway.nix
            agenix.nixosModules.default
          ];
        };

        "7945hx" = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };

          modules = uiModules ++ [
            ./hosts/7945hx/hardware-configuration.nix
            ./hosts/7945hx/fs.nix
            ./gnome.nix
            ./vm.nix
            agenix.nixosModules.default
          ];
        };

        vm = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };

          modules = [
            ./vm.nix
            ./ssh.nix
            (
              { pkgs, ... }:
              {
                environment.systemPackages = with pkgs; [
                  spice-vdagent
                ];
              }
            )
          ];
        };
      };
    };
}
