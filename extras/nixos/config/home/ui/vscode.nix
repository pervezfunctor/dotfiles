{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;

    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        catppuccin.catppuccin-vsc
        catppuccin.catppuccin-vsc-icons
        charliermarsh.ruff
        codezombiech.gitignore
        donjayamanne.githistory
        github.github-vscode-theme
        gruntfuggly.todo-tree
        jnoortheen.nix-ide
        mads-hartmann.bash-ide-vscode
        ms-azuretools.vscode-docker
        ms-python.debugpy
        ms-python.python
        ms-python.vscode-pylance
        ms-vscode-remote.remote-containers
        ms-vscode-remote.remote-ssh
        ms-vscode-remote.remote-ssh-edit
        mvllow.rose-pine
        redhat.vscode-yaml
        tamasfe.even-better-toml
        thenuprojectcontributors.vscode-nushell-lang
        timonwong.shellcheck
        yzhang.markdown-all-in-one
        zxh404.vscode-proto3
        # sclu1034.justfile
      ];

      #   userSettings = {
      #     "editor.acceptSuggestionOnEnter" = "smart";
      #     "editor.autoIndent" = "advanced";
      #     "editor.cursorSmoothCaretAnimation" = "on";
      #     "editor.find.autoFindInSelection" = "never";
      #     "editor.fontFamily" = "'JetbrainsMono Nerd Font Mono', 'monospace'";
      #     "editor.fontSize" = 15;
      #     "editor.formatOnPaste" = true;
      #     "editor.formatOnSave" = true;
      #     "editor.indentSize" = "tabSize";
      #     "editor.detectIndentation" = false;
      #     "editor.insertSpaces" = true;
      #     "editor.minimap.enabled" = false;
      #     "editor.renderWhitespace" = "boundary";
      #     "editor.rulers" = [ 80 ];
      #     "editor.smoothScrolling" = true;
      #     "editor.snippetSuggestions" = "bottom";
      #     "editor.tabCompletion" = "on";
      #     "editor.tabSize" = 2;
      #     "editor.trimAutoWhitespace" = true;

      #     "files.autoSave" = "onFocusChange";
      #     "files.insertFinalNewline" = true;
      #     "files.trimTrailingWhitespace" = true;

      #     "git.autofetch" = true;

      #     "nix.enableLanguageServer" = true;
      #     "nix.formatterPath" = "alejandra";
      #     "nix.serverPath" = "nixd";

      #     "update.mode" = "manual";

      #     "window.titleBarStyle" = "custom";

      #     "workbench.colorTheme" = "Catppuccin Mocha";
      #     "workbench.sideBar.location" = "right";
      #     "docker.extension.enableComposeLanguageServer" = true;
      #     "github.copilot.enable" = {
      #       "*" = false;
      #     };
      #     "workbench.startupEditor" = "none";
      #   };
    };
  };
}
