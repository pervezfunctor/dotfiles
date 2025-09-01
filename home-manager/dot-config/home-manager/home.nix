{ pkgs, vars, ... }:

{
  home.username = vars.username;
  home.homeDirectory = vars.homeDirectory;

  imports = [
    ./packages.nix
    ./programs.nix
  ];

  home.stateVersion = "25.11";

  news.display = "silent";
}
