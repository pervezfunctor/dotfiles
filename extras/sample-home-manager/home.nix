{
  config,
  pkgs,
  isLinux,
  isDarwin,
  ...
}:

{
  home.username = "youruser";
  home.homeDirectory = if isDarwin then "/Users/youruser" else "/home/youruser";

  home.stateVersion = "25.11";

  home.packages =
    with pkgs;
    [
      git
      vim
      htop
      curl
      wget
    ]
    ++ (
      if isLinux then
        [
          firefox
        ]
      else
        [
          aerospace
        ]
    );

  home.sessionVariables = {
    EDITOR = "vim";
  }
  // (
    if isDarwin then
      {
        # macOS-specific environment variables
      }
    else
      {
        # Linux-specific environment variables
      }
  );

  programs.home-manager.enable = true;
}
