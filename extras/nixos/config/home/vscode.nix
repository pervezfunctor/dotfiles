{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;

    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        charliermarsh.ruff
        codezombiech.gitignore
        docker.docker
        donjayamanne.githistory
        github.github-vscode-theme
        github.vscode-github-actions
        gruntfuggly.todo-tree
        jnoortheen.nix-ide
        kilocode.kilo-code
        mads-hartmann.bash-ide-vscode
        mechatroner.rainbow-csv
        mhutchie.git-graph
        ms-azuretools.vscode-containers
        ms-azuretools.vscode-docker
        ms-python.debugpy
        ms-python.python
        ms-python.vscode-pylance
        ms-vscode-remote.remote-containers
        ms-vscode-remote.remote-ssh
        ms-vscode-remote.remote-ssh-edit
        ms-vscode.remote-explorer
        quicktype.quicktype
        redhat.vscode-yaml
        tamasfe.even-better-toml
        thenuprojectcontributors.vscode-nushell-lang
        timonwong.shellcheck
        usernamehw.errorlens
        vincaslt.highlight-matching-tag
        yzhang.markdown-all-in-one
        zxh404.vscode-proto3
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
