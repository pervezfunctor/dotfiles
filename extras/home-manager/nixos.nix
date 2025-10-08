{
  inputs,
  vars,
  hmModule,
  osImports ? [ ],
  nixpkgs ? inputs.nixpkgs,
  home-manager ? inputs.home-manager,
}:
let
  system = "x86_64-linux";
  pkgs = nixpkgs.legacyPackages.${system};
in
nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit inputs vars; };

  modules = [
    ./hardware-configuration.nix

    ./system/nixos
    ./system/core.nix
    ./system/ui.nix
  ]
  ++ osImports
  ++ [
    {
      environment.systemPackages = with pkgs; [
        wl-clipboard
        ptyxis
        nerd-fonts.jetbrains-mono
      ];
    }

    home-manager.nixosModules.home-manager
    hmModule
  ];
}
