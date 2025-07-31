{
  description =
    "Offline iPXE PXE-Server + QCOW2 generator with Samba ISO storage";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-generators.url = "github:nix-community/nixos-generators";
  };

  outputs = { self, nixpkgs, flake-utils, nixos-generators, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages.proxmoxVma = nixos-generators.nixosGenerate {
          system = "x86_64-linux";
          format = "proxmox";
          modules = [ ./nixos/configuration.nix ];
        };
      });
}
