{ config, home, ... }:

let
  dotDir = home.homeDirectory + "/.ilm";
in
{
  programs.home-manager = {
    enable = true;
  };

  home.file = {
    ".zshrc" = {
      source = "${dotDir}/zsh/dot-zshrc";
    };

    ".config/tmux/tmux.conf" = {
      source = "${dotDir}/tmux/dot-config/tmux/tmux.conf";
    };

    ".config/Code/User/settings.json" = {
      source = "${dotDir}/extras/vscode/minimal-settings.json";
    };

    ".config/nvim" = config.lib.file.mkOutOfStoreSymlink "${dotDir}/ilm/nvim/dot-config/nvim";
  };
}
