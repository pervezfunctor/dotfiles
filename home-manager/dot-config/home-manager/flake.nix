{
  description = "ILM home-manager flake";

  inputs =
    {
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

      home-manager = {
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };

  outputs =
    {
      nixpkgs,
      home-manager,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      vars = import ./vars.nix;
    in
    {
      homeConfigurations."${vars.username}" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = {
          inherit vars;
        };

        modules = [ ./home.nix ];
      };
    };
}
