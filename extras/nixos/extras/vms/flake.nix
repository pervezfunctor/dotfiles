{
  description = "NixOS VM configuration";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; };

  outputs = { self, nixpkgs, ... }:
    let system = "x86_64-linux";
    in {
      nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ ./vm.nix ];
      };

      nixosConfigurations.gnome-vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./gnome-vm.nix ];
      };

      nixosConfigurations.kde-vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./kde-vm.nix ];
      };

      packages.${system} = {
        vm = self.nixosConfigurations.vm.config.system.build.vm;
        gnome-vm = self.nixosConfigurations.gnome-vm.config.system.build.vm;
        kde-vm = self.nixosConfigurations.kde-vm.config.system.build.vm;
      };
    };
}
