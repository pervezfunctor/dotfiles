{ pkgs, vars, ... }:
{
  # Enable greetd as a display manager for Hyprland
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  services.getty = {
    autologinUser = vars.username;
    autologinOnce = true;
  };

  programs.regreet.enable = true;
  # environment.systemPackages = with pkgs; [ tuigreet ];
}
