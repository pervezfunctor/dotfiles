{ inputs, vars, ... }:
let
  nixvim = inputs.nixvim;
in
{
  imports = [
    ./packages.nix
    ./programs.nix
    ./bash.nix
    ./zsh.nix
    ./shell.nix
    nixvim.homeModules.nixvim
    ./nvim.nix
    ./ui.nix
  ];

  home = {
    stateVersion = "25.11";
    username = "${vars.username}";
    homeDirectory = "/home/${vars.username}";
  };
}

# sessionVariables = {
#   SSH_AUTH_SOCK = "/run/user/1000/keyring/ssh";
# };

# file.".xprofile".text = ''
#   eval $(gnome-keyring-daemon --start)
#   export SSH_AUTH_SOCK
# '';

# pointerCursor = {
#   name = "Adwaita";
#   package = pkgs.adwaita-icon-theme;
#   size = 24;
#   x11 = {
#     enable = true;
#     defaultCursor = "Adwaita";
#   };
#   sway.enable = true;
# };

# dconf.settings = {
#   "org/virt-manager/virt-manager/connections" = {
#     autoconnect = [ "qemu:///system" ];
#     uris = [ "qemu:///system" ];
#   };
# };

# stylix = {
#   enable = true;

#   # base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";

#   image = /home/me/.ilm/wallpapers/dot-config/wallpapers/wallpaper.png;
#   polarity = "dark";
# };
