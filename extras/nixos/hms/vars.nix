{ ... }:

{
  userName = builtins.getEnv "USER";
  homeDirectory = builtins.getEnv "HOME";
}
