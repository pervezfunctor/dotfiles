{
  inputs,
  vars,
  hmModule,
  nixpkgs ? inputs.nixpkgs,
  nixos-wsl ? inputs.nixos-wsl,
  home-manager ? inputs.home-manager,
}:
nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs vars; };

  modules = [
    {
      programs.nix-ld.enable = true;
      # services.nix-daemon.enable = true;
      wsl.enable = true;
    }

    nixos-wsl.nixosModules.default
    home-manager.nixosModules.home-manager
    hmModule
  ];
}
