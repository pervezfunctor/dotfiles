{
  description = "ILM NixOS configuration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";

    flake-parts.url = "github:hercules-ci/flake-parts";

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
      nixvim,
      catppuccin,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
      vars = import ./vars.nix { inherit pkgs; };

      commonHomeModules = [
        ./home/packages.nix
        ./home/bash.nix
        ./home/zsh.nix
        ./home/gtk.nix
        ./home/vscode.nix
      ];

      homeModules = commonHomeModules ++ [
        ./home/vscode-settings.nix
        ./home/ghostty.nix
        nixvim.homeModules.nixvim
        ./home/programs.nix
        catppuccin.homeModules.catppuccin
      ];

      mkHomeModule = homeModules: {
        home-manager = {
          extraSpecialArgs = {
            inherit inputs;
            inherit vars;
          };

          useUserPackages = true;
          useGlobalPkgs = true;
          backupFileExtension = "backup";
          users.${vars.username} = import ./home.nix {
            inherit vars;
            imports = homeModules;
          };
        };
      };

      defaultHomeModule = mkHomeModule homeModules;

      commonModules = [
        stylix.nixosModules.stylix
        ./system/configuration.nix
        quadlet-nix.nixosModules.quadlet
        catppuccin.nixosModules.catppuccin
        # nixvim.nixosModules.nixvim
        home-manager.nixosModules.home-manager
      ];

      uiModules = commonModules ++ [ ./system/ui.nix ];

      guestModules = [
        ./system/systemd-boot.nix
        ./system/guest.nix
        ./system/user.nix
        ./system/ssh.nix
        ./system/virt/rootfs.nix
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

      # WIP
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
      mkUiWithHome = extraModules: mkUiSystem ([ defaultHomeModule ] ++ extraModules);

      mkBareMetalSystem =
        extraModules: mkNixosSystem (uiModules ++ extraModules ++ [ agenix.nixosModules.default ]);
      mkBareMetalWithHome = extraModules: mkBareMetalSystem (extraModules ++ [ defaultHomeModule ]);

      mkSimpleVmSystem = extraModules: mkNixosSystem (commonModules ++ guestModules ++ extraModules);
      mkSimpleVmWithHome = extraModules: mkSimpleVmSystem ([ defaultHomeModule ] ++ extraModules);

      mkVmSystem =
        extraModules: mkNixosSystem (commonModules ++ guestModules ++ uiModules ++ extraModules);
      mkVmWithHome = extraModules: mkVmSystem ([ defaultHomeModule ] ++ extraModules);

      mkNixosGenerateCommon =
        extraModules: format:
        nixos-generators.nixosGenerate {
          inherit system;
          specialArgs = {
            pkgs = pkgs;
            inherit inputs;
            inherit vars;
          };
          modules = commonModules ++ guestModules ++ extraModules; # ++ [ { virtualisation.diskImage.size = "20G"; } ];
          format = format;
        };

      mkNixosGenerateVm = extraModules: mkNixosGenerateCommon extraModules "vm";
      mkNixosGenerateVmWithHome = extraModules: mkNixosGenerateVm (extraModules ++ [ defaultHomeModule ]);

      mkNixosGenerateProxmox =
        extraModules: mkNixosGenerateCommon (extraModules ++ [ ./system/proxmox.nix ]) "proxmox";
      mkNixosGenerateProxmoxWithHome =
        extraModules: mkNixosGenerateProxmox (extraModules ++ [ defaultHomeModule ]);

      mkAnywhereSystem = extraModules: mkBareMetalSystem (extraModules ++ [ disko.nixosModules.disko ]);
      mkAnywhereWithHome = extraModules: mkAnywhereSystem (extraModules ++ [ defaultHomeModule ]);
    in
    {
      homeConfigurations = {
        "nixos" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ defaultHomeModule ];
        };

        ${vars.username} = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit inputs vars; };
          modules = [ defaultHomeModule ];
        };
      };

      nixosConfigurations = {
        "um580" = mkBareMetalWithHome [
          ./hosts/um580/hardware-configuration.nix
          ./hosts/generic/fs.nix
          ./system/sway.nix
        ];

        "7945hx" = mkBareMetalWithHome [
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

        # examples

        # default = mkNixosSystem [
        #   uiModules
        #   mkHomeModule
        #   [
        #     ./home/packages.nix
        #     ./home/zsh.nix
        #   ]
        # ];

        # server = mkNixosSystem (commonModules ++ [ ./system/ssh.nix ]);
        # gnome = mkUiWithHome [ ./system/gnome.nix ];
        # kde = mkUiWithHome [ ./system/kde.nix ];
        # sway = mkUiWithHome [ ./system/sway.nix ];

        # virtual machines
        kde-vm = mkVmSystem [ ./system/kde.nix ];
        gnome-vm = mkVmSystem [ ./system/gnome.nix ];
        sway-vm = mkVmWithHome [ ./system/sway.nix ];
        docker-vm = mkSimpleVmWithHome [ ./system/virt/docker.nix ];
        incus-vm = mkSimpleVmWithHome [ ./system/virt/incus.nix ];
        podman-vm = mkSimpleVmWithHome [ ./system/virt/podman.nix ];

        "anywhere-${vars.hostName}" = mkAnywhereWithHome [
          ./system/disko-config.nix
          ./system/gnome.nix
          ./system/ssh.nix
        ];

        # WIP
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

      packages.${system} = {
        # use with nix build .#ng-vm
        ng-vm = mkNixosGenerateVmWithHome [ ];

      };
    };
}
