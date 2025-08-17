{ config, home, ... }:
{
  programs.home-manager = {
    enable = true;
  };

  home.file = {
    ".zshrc" = {
      source = "${builtins.getEnv "HOME"}/.ilm/zsh/dot-zshrc";
    };

    ".config/tmux/tmux.conf" = {
      source = "${builtins.getEnv "HOME"}/.ilm/tmux/dot-config/tmux/tmux.conf";
    };

    ".config/Code/User/settings.json" = {
      source = "${builtins.getEnv "HOME"}/.ilm/extras/vscode/minimal-settings.json";
    };

    ".config/nvim" =
      config.lib.file.mkOutOfStoreSymlink "${home.homeDirectory}/.ilm/nvim/dot-config/nvim";
  };
}
