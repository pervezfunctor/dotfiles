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
      url = "github:nix-community/stylix";
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

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    xc = {
      url = "github:joerdav/xc";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
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
      nixos-generators,
      microvm,
      nixos-wsl,
      # nixvim,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      vars = import ./vars.nix { inherit pkgs; };

      commonModules = [
        stylix.nixosModules.stylix
        ./system/configuration.nix
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
            users.${vars.username} = import ./home/home.nix;
          };
        }
      ];

      uiModules = commonModules ++ [ ./system/ui.nix ];

      guestModules = commonModules ++ [
        ./system/systemd-boot.nix
        ./system/guest.nix
        ./system/user.nix
        ./system/ssh.nix
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

      mkWSLSystem =
        modules: homeNix:
        nixpkgs.lib.nixosSystem {
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
                  # inherit vars;
                };

                useUserPackages = true;
                useGlobalPkgs = true;
                backupFileExtension = "backup";

                users.nixos = import homeNix;
              };
            }
          ]
          ++ modules;
        };

      mkUiSystem = extraModules: mkNixosSystem (uiModules ++ extraModules);

      mkBareSystem =
        extraModules: mkNixosSystem (uiModules ++ extraModules ++ [ agenix.nixosModules.default ]);

      mkSimpleVmSystem = extraModules: mkNixosSystem (extraModules ++ guestModules);

      mkVmSystem = extraModules: mkNixosSystem (uiModules ++ extraModules ++ guestModules);

      mkNixosGenerateCommon =
        extraModules: format:
        nixos-generators.nixosGenerate {
          inherit system;
          specialArgs = {
            pkgs = pkgs;
            inherit inputs;
            inherit vars;
          };
          modules = extraModules ++ guestModules; # ++ [ { virtualisation.diskImage.size = "20G"; } ];
          format = format;
        };

      mkNixosGenerateVm = extraModules: mkNixosGenerateCommon extraModules "vm";

      mkNixosGenerateProxmox =
        extraModules: mkNixosGenerateCommon extraModules ++ [ ./system/proxmox.nix ] "proxmox";

      mkAnywhereSystem = extraModules: mkBareSystem (extraModules ++ [ disko.nixosModules.disko ]);
    in
    {
      homeConfigurations = {
        "nixos" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home.nix ];
        };

        ${vars.username} = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = { inherit inputs vars; };
          modules = [
            # nixvim.homeManagerModules.nixvim
            # stylix.homeModules.stylix
            ./home/home.nix
          ];
        };
      };

      nixosConfigurations = {
        server = mkNixosSystem (commonModules ++ [ ./system/ssh.nix ]);

        gnome = mkUiSystem [ ./system/gnome.nix ];
        gnome-vm = mkVmSystem [ ./system/gnome.nix ];

        kde = mkUiSystem [ ./system/kde.nix ];
        kde-vm = mkVmSystem [ ./system/kde.nix ];

        sway = mkUiSystem [ ./system/sway.nix ];
        sway-vm = mkVmSystem [ ./system/sway.nix ];

        docker-vm = mkSimpleVmSystem [ ./system/virt/docker.nix ];
        incus-vm = mkSimpleVmSystem [ ./system/virt/incus.nix ];
        podman-vm = mkSimpleVmSystem [ ./system/virt/podman.nix ];

        anywhere."${vars.hostName}" = mkAnywhereSystem [
          ./system/disko-config.nix
          ./system/gnome.nix
          ./system/ssh.nix
          ./hosts/${vars.hostName}/hardware-configuration.nix
        ];

        um580 = mkBareSystem [
          ./hosts/um580/hardware-configuration.nix
          ./hosts/um580/fs.nix
          ./system/sway.nix
        ];

        # run with nix build .#ng-vm
        ng-vm = mkNixosGenerateVm [ ];

        # run with nix build .#ng-pmox
        ng-pmox = mkNixosGenerateProxmox [ ];

        "7945hx" = mkBareSystem [
          ./hosts/7945hx/hardware-configuration.nix
          ./system/cosmic.nix
          ./system/apps.nix
          ./system/vm-ui.nix
        ];

        "nuc12" = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
            inherit vars;
          };
          modules = [
            ./hosts/nuc12/configuration.nix
          ];
        };

        wsl = mkWSLSystem [ ] ./home.nix;

        basic-microvm = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
            inherit vars;
          };
          modules = [
            microvm.nixosModules.microvm
            {
              networking.hostName = "basic-microvm";
              microvm.hypervisor = "cloud-hypervisor";

              # microvm.shares = [
              #   {
              #     tag = "ro-store";
              #     source = "/nix/store";
              #     mountPoint = "/nix/.ro-store";
              #   }

              #   # {
              #   #   proto = "virtiofs";
              #   #   tag = "home";
              #   #   source = "home";
              #   #   mountPoint = "/home";
              #   # }
              # ];

              # microvm.vcpu = 2;
              # microvm.mem = 4096;
              # microvm.interfaces = "";
              # microvm.volumes = "";
              # microvm.shares = "";
              # microvm.devices = "";
              # microvm.socket = "";
              # microvm.user = "";
              # microvm.forwardPorts = "";
              # microvm.kernelParams = "";
              # microvm.storeOnDisk = "";
              # microvm.writableStoreOverlay = "";
            }
          ];
        };
      };
    };
}
