{ ... }:

{
  username = builtins.getEnv "USER";
  homeDirectory = builtins.getEnv "HOME";
  gitUserName = "<Username>";
  gitUserEmail = "<emailid>";
}
