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
      wsl.defaultUser = "nixos";
      wsl.enable = true;
      system.stateVersion = "25.11";

      environment.systemPackages = with nixpkgs.legacyPackages.x86_64-linux; [
        bash
        coreutils
        curl
        dialog
        file
        gawk
        gcc
        git
        glibc
        gnugrep
        gnumake
        micro
        newt
        tree
        unzip
        wget
        zsh
        zstd
      ];
    }

    nixos-wsl.nixosModules.default
    home-manager.nixosModules.home-manager
    hmModule
  ];
}
