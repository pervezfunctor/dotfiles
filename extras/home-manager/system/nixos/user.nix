{ pkgs, vars, ... }:
{
  users.defaultUserShell = pkgs.zsh;
  users.users = {
    "${vars.username}" = {
      isNormalUser = true;
      shell = pkgs.zsh;
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
    };
  };

  programs.zsh.enable = true;
}
