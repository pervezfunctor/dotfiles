{ inputs, ... }:
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia-shell = {
    enable = true;
    systemd.enable = false;
  };

  # systemd.user.targets.mango-session = {
  #   Unit = {
  #     Description = "mango compositor session";
  #     Requires = [ "graphical-session.target" ];
  #     After = [ "graphical-session.target" ];
  #   };
  # };

  # systemd.user.services.noctalia-shell = {
  #   Unit = {
  #     Description = "Mango Session Service";
  #     PartOf = [ "mango-session.target" ];
  #   };

  #   Service = {
  #     Type = "simple";
  #     ExecStart = "${pkgs.noctalia-shell}/bin/noctalia-shell";
  #   };

  #   Install = {
  #     WantedBy = [ "mango-session.target" ];
  #   };
  # };
}
