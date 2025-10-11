{
  inputs,
  vars,
  hmModule,
  osImports ? [ ],
  nixpkgs ? inputs.nixpkgs,
  nixos-wsl ? inputs.nixos-wsl,
  home-manager ? inputs.home-manager,
}:
nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs vars; };

  modules = [
    ./system/nixos/core.nix
    ./system/core.nix
  ]
  ++ osImports
  ++ [
    {
      programs.nix-ld.enable = true;
      wsl.defaultUser = vars.username;
      wsl.enable = true;
      system.stateVersion = "25.11";
    }

    nixos-wsl.nixosModules.default
    home-manager.nixosModules.home-manager
    hmModule
  ];
}
