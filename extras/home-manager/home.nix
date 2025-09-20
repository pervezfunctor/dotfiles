{
  vars,
  imports ? [ ],
  ...
}:

{
  inherit imports;

  home.username = vars.username;
  home.homeDirectory = vars.homeDirectory;

  programs.home-manager.enable = true;

  home.stateVersion = "24.11";

  news.display = "silent";
}
