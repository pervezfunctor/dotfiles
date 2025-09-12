{ vars, ... }:

{
  home.username = vars.username;
  home.homeDirectory = vars.homeDirectory;

  imports = [
    ./core.nix
    # ./programs.nix
  ];

  programs.home-manager.enable = true;

  home.stateVersion = "25.11";

  news.display = "silent";
}
