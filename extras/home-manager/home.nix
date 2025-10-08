{
  vars,
  imports,
  ...
}:
{
  inherit imports;

  home.username = vars.username;
  home.homeDirectory = vars.homeDirectory;

  programs.home-manager.enable = true;

  news.display = "silent";
  home.stateVersion = "25.11";
}
