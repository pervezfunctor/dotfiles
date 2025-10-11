{
  inputs,
  vars,
  hmModule,
  osImports ? [ ],
  darwin ? inputs.darwin,
  home-manager ? inputs.home-manager,
}:
darwin.lib.darwinSystem {
  system = "aarch64-darwin";
  specialArgs = { inherit inputs vars; };

  modules = [
    ./system/core.nix
  ]
  ++ osImports
  ++ [
    {
      system.stateVersion = 6;
      nix.enable = false;
      homebrew.enable = true;
      system.primaryUser = vars.username;

      users.users.${vars.username} = {
        home = vars.homeDirectory;
      };
    }

    home-manager.darwinModules.home-manager
    hmModule
  ];
}
