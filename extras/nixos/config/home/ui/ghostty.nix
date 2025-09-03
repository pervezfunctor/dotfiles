{ ... }:
{
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    installBatSyntax = true;
    installVimSyntax = true;
    settings = {
      font-family = "JetBrainsMono Nerd Font";
      font-size = 12;
      background-blur-radius = 20;
      mouse-hide-while-typing = true;
      window-decoration = true;
      macos-option-as-alt = true;
      background-opacity = 0.90;
      theme = "catppuccin-mocha";
      # theme = "Everforest Dark - Hard";

      # keybind = [
      #   "ctrl+h=goto_split:left"
      #   "ctrl+l=goto_split:right"
      #   "ctrl+j=goto_split:down"
      #   "ctrl+k=goto_split:up"
      #   "ctrl+shift+h=move_split:left"
      #   "ctrl+shift+l=move_split:right"
      #   "ctrl+shift+j=move_split:down"
      #   "ctrl+shift+k=move_split:up"
      #   "ctrl+shift+q=quit"
      #   "ctrl+shift+o=split:horizontal"
      #   "ctrl+shift+i=split:vertical"
      #   "ctrl+shift+w=close_split"
      #   "ctrl+shift+e=close_window"
      #   "ctrl+shift+f=toggle_fullscreen"
      # ];
    };
  };
}
