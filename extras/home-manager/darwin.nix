{
  # pkgs,
  inputs,
  vars,
  hmModule,
  darwin ? inputs.darwin,
  home-manager ? inputs.home-manager,
}:
darwin.lib.darwinSystem {
  system = "aarch64-darwin";
  specialArgs = { inherit inputs vars; };

  modules = [
    {
      system.stateVersion = 6;
      nix.enable = false;
      homebrew.enable = true;
      system.primaryUser = vars.username;

      users.users.${vars.username} = {
        home = vars.homeDirectory;
      };

      # environment.systemPackages = with pkgs; [
      # ];
    }

    home-manager.darwinModules.home-manager
    hmModule
  ];
}
