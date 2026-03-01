{ vars, pkgs, ... }:

{
  home.username = vars.username;
  home.homeDirectory = vars.homeDirectory;
  home.stateVersion = "25.11";

  home.pointerCursor = {
    # gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 32;
  };

  home.packages = with pkgs; [
    kitty
  ];

  programs = {
    home-manager.enable = true;
  };

  home.file = {
    ".config/kitty/kitty.conf" = {
      source = ../config/kitty/kitty.conf;
      force = true;
    };
  };
}
