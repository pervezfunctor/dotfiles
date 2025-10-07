{
  description = "A minimal NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # Or a specific stable branch like "nixos-23.11"
  };

  outputs = { self, nixpkgs }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux"; # Or your system's architecture
      modules = [
        ./configuration.nix
      ];
    };
  };
}
