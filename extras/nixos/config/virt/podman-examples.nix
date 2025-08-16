{
  description = "NixOS configuration with Podman and Quadlet support";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    quadlet-nix = {
      url = "github:SEIAROTg/quadlet-nix";
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
      quadlet-nix,
      home-manager,
    }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.container-host = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hardware-configuration.nix

          quadlet-nix.nixosModules.quadlet

          home-manager.nixosModules.home-manager

          (
            { config, pkgs, ... }:
            {
              system.stateVersion = "25.11";

              nix.settings.experimental-features = [
                "nix-command"
                "flakes"
              ];

              virtualisation.containers = {
                enable = true;
                registries.search = [
                  "registry.fedoraproject.org"
                  "registry.access.redhat.com"
                  "quay.io"
                  "docker.io"
                ];
              };

              virtualisation.podman = {
                enable = true;
                dockerCompat = true;
                defaultNetwork.settings.dns_enabled = true;
                dockerSocket.enable = true;
                autoPrune = {
                  enable = true;
                  dates = "weekly";
                };
              };

              virtualisation.quadlet = {
                containers = {
                  nginx = {
                    image = "docker.io/nginx:alpine";
                    autoUpdate = "registry";
                    ports = [ "8080:80" ];
                    volumes = [
                      "/var/log/nginx:/var/log/nginx:Z"
                    ];
                    environment = {
                      NGINX_PORT = "80";
                    };
                    healthCheck = {
                      command = [
                        "curl"
                        "-f"
                        "http://localhost:80/"
                      ];
                      interval = "30s";
                      retries = 3;
                      startPeriod = "60s";
                    };
                    unitConfig = {
                      Description = "Nginx Web Server";
                      After = [ "network-online.target" ];
                      Wants = [ "network-online.target" ];
                    };
                    serviceConfig = {
                      Restart = "always";
                      TimeoutStartSec = 900;
                    };
                  };

                  postgres = {
                    image = "docker.io/postgres:15-alpine";
                    autoUpdate = "registry";
                    networks = [ "app-network" ];
                    volumes = [
                      "postgres-data:/var/lib/postgresql/data:Z"
                    ];
                    environment = {
                      POSTGRES_DB = "myapp";
                      POSTGRES_USER = "appuser";
                      POSTGRES_PASSWORD = "secure_password";
                    };
                    unitConfig = {
                      Description = "PostgreSQL Database";
                    };
                    serviceConfig = {
                      Restart = "always";
                    };
                  };

                  redis = {
                    image = "docker.io/redis:7-alpine";
                    autoUpdate = "registry";
                    networks = [ "app-network" ];
                    volumes = [
                      "redis-data:/data:Z"
                    ];
                    command = [
                      "redis-server"
                      "--appendonly"
                      "yes"
                    ];
                    unitConfig = {
                      Description = "Redis Cache";
                    };
                    serviceConfig = {
                      Restart = "always";
                    };
                  };
                };

                networks = {
                  app-network = {
                    subnet = "10.89.1.0/24";
                    gateway = "10.89.1.1";
                    dns = "10.89.1.1";
                    unitConfig = {
                      Description = "Application Network";
                    };
                  };
                };

                pods = {
                  web-stack = {
                    networks = [ "app-network" ];
                    ports = [
                      "80:80"
                      "443:443"
                    ];
                    unitConfig = {
                      Description = "Web Application Stack";
                    };
                  };
                };

                volumes = {
                  postgres-data = {
                    unitConfig = {
                      Description = "PostgreSQL Data Volume";
                    };
                  };
                  redis-data = {
                    unitConfig = {
                      Description = "Redis Data Volume";
                    };
                  };
                };
              };

              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.myuser =
                  { ... }:
                  {

                    virtualisation.quadlet = {
                      containers = {
                        dev-env = {
                          image = "docker.io/node:18-alpine";
                          autoUpdate = "registry";
                          ports = [ "3000:3000" ];
                          volumes = [
                            "${config.users.users.myuser.home}/projects:/workspace:Z"
                          ];
                          workingDir = "/workspace";
                          command = [
                            "sh"
                            "-c"
                            "sleep infinity"
                          ];
                          unitConfig = {
                            Description = "Development Environment";
                          };
                          serviceConfig = {
                            Restart = "always";
                          };
                        };
                      };
                    };

                    home.stateVersion = "25.11";
                  };
              };

              environment.systemPackages = with pkgs; [
                podman
                podman-compose
                podman-tui
                buildah
                skopeo
                dive
                ctop
                lazydocker
              ];

              users.users.myuser = {
                isNormalUser = true;
                extraGroups = [
                  "wheel"
                  "podman"
                ];
                subUidRanges = [
                  {
                    startUid = 100000;
                    count = 65536;
                  }
                ];
                subGidRanges = [
                  {
                    startGid = 100000;
                    count = 65536;
                  }
                ];
              };

              security.unprivilegedUsernsClone = true;
              systemd.enableUnifiedCgroupHierarchy = true;

              networking = {
                hostName = "container-host";
                firewall = {
                  enable = true;
                  allowedTCPPorts = [
                    22
                    80
                    443
                    8080
                  ];
                  checkReversePath = false;
                };
              };
              services.openssh = {
                enable = true;
                settings = {
                  PermitRootLogin = "no";
                  PasswordAuthentication = false;
                };
              };
              systemd.services.container-auto-update = {
                description = "Auto-update containers";
                serviceConfig = {
                  Type = "oneshot";
                  ExecStart = "${pkgs.podman}/bin/podman auto-update";
                };
              };

              systemd.timers.container-auto-update = {
                wantedBy = [ "timers.target" ];
                partOf = [ "container-auto-update.service" ];
                timerConfig = {
                  OnCalendar = "daily";
                  Persistent = true;
                  RandomizedDelaySec = "1h";
                };
              };
            }
          )
        ];
      };

      devShells.${system}.default = nixpkgs.legacyPackages.${system}.mkShell {
        buildInputs = with nixpkgs.legacyPackages.${system}; [
          podman
          podman-compose
          buildah
          skopeo
          dive
          ctop
          lazydocker
          kubernetes-helm
          kubectl
        ];

        shellHook = ''
          echo "Container management environment loaded"
          echo "Available tools: podman, buildah, skopeo, dive, ctop, lazydocker"
          echo ""
          echo "Useful commands:"
          echo "  podman ps -a                    # List all containers"
          echo "  systemctl status <name>.service # Check Quadlet service status"
          echo "  podman auto-update             # Update containers"
          echo "  systemctl --user daemon-reload # Reload user Quadlet configs"
        '';
      };
    };
}
