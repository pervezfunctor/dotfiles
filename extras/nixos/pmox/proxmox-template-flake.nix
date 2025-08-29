{
  description = "NixOS Proxmox template image";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      lib,
      flake-utils,
      nixos-generators,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (system: {
      packages.proxmox-template = nixos-generators.nixosGenerate {
        inherit system;
        format = "qcow2";
        modules = [
          (
            { pkgs, ... }:
            {
              services.cloud-init = {
                enable = true;
                datasources = [
                  "NoCloud"
                  "ConfigDrive"
                ];
              };

              services.qemuGuest.enable = true;

              services.openssh.enable = true;

              users.mutableUsers = false;
              users.users.root = {
                isNormalUser = false;
                hashedPassword = "!"; # disables password login
              };

              environment.systemPackages = with pkgs; [
                vim
                curl
                git
              ];

              networking.useNetworkd = true;
              networking.firewall.allowedTCPPorts = [ 22 ];

              boot.loader.systemd-boot.enable = true;
              boot.loader.efi.canTouchEfiVariables = true;

              ## Faster boots in VMs
              services.getty.autologin = lib.mkForce null;
            }
          )
        ];
      };
    });
}
