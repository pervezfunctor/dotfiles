{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";

  # enable gnome
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  outputs =
    {
      nixpkgs,
      disko,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      vars = import ./vars.nix { inherit pkgs; };
    in
    {
      # nixos-anywhere --flake .#<hostname> --generate-hardware-config nixos-generate-config ./hardware-configuration.nix <remote-host-ip>
      nixosConfigurations."${vars.hostName}" = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          disko.nixosModules.disko
          ./disko-config.nix
          ./configuration.nix
          ./hardware-configuration.nix
        ];
      };
    };
}
