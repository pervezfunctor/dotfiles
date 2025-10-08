{ pkgs, ... }:
{
  users.defaultUserShell = pkgs.zsh;
  users.users.pervez = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Pervez Iqbal";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };
  programs.zsh.enable = true;
}
