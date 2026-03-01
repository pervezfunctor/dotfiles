{ inputs, ... }:
{
  imports = [
    inputs.dms.homeModules.dank-material-shell
    # inputs.dms.homeModules.niri
  ];

  programs.dank-material-shell = {
    enable = true;

    enableSystemMonitoring = true;
    enableDynamicTheming = true;

    systemd = {
      enable = false;
      restartIfChanged = true;
    };
  };
}
