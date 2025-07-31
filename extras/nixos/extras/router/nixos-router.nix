# ## Hardened Bare-Metal NixOS Router Configuration (Flake-based)
# This flake provides a secure, headless router setup with nftables, dnsmasq,
# WireGuard, VRRP failover, centralized logging, alerting, and monitoring.

{
  description = "Hardened NixOS Router for bare metal";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    agenix.url = "github:ryantm/agenix";
  };

  outputs = { self, nixpkgs, flake-utils, agenix, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = false;
        };
      in {
        packages.router-image = pkgs.callPackage (import (pkgs.fetchFromGitHub {
          owner = "nix-community";
          repo = "nixos-generators";
          rev = "master";
          sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
        })) { }.nixos-generate {
          format = "install-iso";
          configuration = self.nixosConfigurations.router;
        };

        nixosConfigurations.router = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            agenix.nixosModules.default
            ({ config, pkgs, lib, ... }: {

              # Host Basics
              networking.hostName = "router";
              networking.useDHCP = false;
              networking.firewall.enable = false; # use nftables instead
              networking.nftables.enable = true;
              networking.nftables.ruleset = ''
                table inet filter {
                  chain input {
                    type filter hook input priority 0;
                    policy drop;

                    ct state established,related accept
                    iif lo accept

                    # Allow SSH from LAN only
                    iifname "lan0" tcp dport 22 accept
                    # Allow DNS
                    udp dport 53 accept
                    tcp dport 53 accept
                    # Allow DHCP (dnsmasq)
                    udp dport 67 accept
                    # Allow ICMP
                    ip protocol icmp accept
                  }

                  chain forward {
                    type filter hook forward priority 0;
                    policy drop;
                    ct state established,related accept
                    iifname "lan0" oifname "wan0" accept
                  }

                  chain output {
                    type filter hook output priority 0;
                    policy accept;
                  }
                }

                table ip nat {
                  chain postrouting {
                    type nat hook postrouting priority 100;
                    oifname "wan0" masquerade
                  }
                }
              '';

              # Interfaces
              networking.interfaces.wan0.useDHCP = true;
              networking.interfaces.lan0.ipv4.addresses = [{
                address = "192.168.1.1";
                prefixLength = 24;
              }];
              networking.defaultGateway = "";
              networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

              # dnsmasq: DHCP + DNS
              services.dnsmasq = {
                enable = true;
                settings = {
                  interface = "lan0";
                  dhcp-range = "192.168.1.100,192.168.1.250,12h";
                  dhcp-option = "3,192.168.1.1";
                  domain-needed = true;
                  bogus-priv = true;
                };
              };

              # WireGuard VPN
              networking.wireguard.interfaces.wg0 = {
                ips = [ "10.100.0.1/24" ];
                listenPort = 51820;
                privateKeyFile = config.age.secrets.wg-private.path;
                peers = [{
                  publicKey = "REPLACE_WITH_PEER_PUBKEY";
                  allowedIPs = [ "10.100.0.2/32" ];
                }];
              };

              age.secrets.wg-private.file = ../secrets/wg-private.age;

              # keepalived: High Availability
              services.keepalived = {
                enable = true;
                vrrpInstances = {
                  VI_1 = {
                    interface = "lan0";
                    virtualRouterId = 51;
                    priority = 100;
                    advertInterval = 1;
                    virtualIpAddresses = [ "192.168.1.1" ];
                  };
                };
              };

              # Logging + Monitoring + Alerting
              services.rsyslog = {
                enable = true;
                extraConfig = ''
                  *.* @@logserver.local:514
                '';
              };

              services.prometheus.exporters.node = {
                enable = true;
                port = 9100;
              };

              services.grafana-agent = {
                enable = true;
                settings = {
                  metrics = {
                    configs = [{
                      name = "default";
                      scrape_configs = [{
                        job_name = "node";
                        static_configs = [{ targets = [ "localhost:9100" ]; }];
                      }];
                    }];
                  };
                  logs = {
                    positions_directory = "/tmp/positions";
                    configs = [{
                      name = "default";
                      clients = [{
                        url = "http://logserver.local:3100/loki/api/v1/push";
                      }];
                    }];
                  };
                };
              };

              services.prometheus.alertmanager = {
                enable = true;
                web.external-url = "http://router:9093";
                configuration = {
                  route = {
                    receiver = "admin";
                    group_wait = "10s";
                    group_interval = "30s";
                    repeat_interval = "1h";
                  };
                  receivers = [{
                    name = "admin";
                    email_configs = [{ to = "admin@example.com"; }];
                  }];
                };
              };

              # System Hardening
              security.sudo.wheelNeedsPassword = true;
              services.openssh = {
                enable = true;
                passwordAuthentication = false;
                permitRootLogin = "no";
              };
              users.users.root.hashedPassword = "!";
              users.users.router = {
                isNormalUser = true;
                extraGroups = [ "wheel" ];
                openssh.authorizedKeys.keys =
                  [ "ssh-ed25519 AAAA... your_key_here" ];
              };

              security.apparmor.enable = true;
              security.audit.enable = true;
              security.lockKernelModules = true;
              boot.kernel.sysctl = {
                "kernel.kptr_restrict" = 2;
                "kernel.randomize_va_space" = 2;
                "net.ipv4.conf.all.rp_filter" = 1;
                "net.ipv4.conf.default.rp_filter" = 1;
                "net.ipv4.tcp_syncookies" = 1;
                "net.ipv4.conf.all.accept_redirects" = 0;
                "net.ipv4.conf.all.send_redirects" = 0;
                "net.ipv6.conf.all.disable_ipv6" = 1;
              };

              environment.systemPackages = with pkgs; [
                dnsutils
                nftables
                wireguard-tools
                keepalived
                prometheus-node-exporter
                curl
                vim
                journalbeat
              ];

              system.stateVersion = "24.05";
            })
          ];
        };
      });
}
