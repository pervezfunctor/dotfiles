{
  description = "Tailscale + dnsmasq router VM";

  inputs.nixpkgs.url = "nixpkgs/nixos-25.11";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages.vm = pkgs.nixosConfigurations.router-vm.config.system.build.vm;
      }) // {
        nixosConfigurations.router-vm = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./vm.nix ];
        };
      };
}
