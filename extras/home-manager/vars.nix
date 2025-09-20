{
  # home-manager standalone
  username = builtins.getEnv "USER";
  homeDirectory = builtins.getEnv "HOME";

  # nixos wsl
  # username = "nixos";
  # homeDirectory = "/home/nixos";

  # darwin
  # username = "pervez";
  # homeDirectory = "/Users/pervez";
  # host = "mac";
}
