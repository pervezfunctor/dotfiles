{
  inputs,
  vars,
  hmModule,
  osImports ? [ ],
  nixpkgs ? inputs.nixpkgs,
  pkgs,
  home-manager ? inputs.home-manager,
}:
nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
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
