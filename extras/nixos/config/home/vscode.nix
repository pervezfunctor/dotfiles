{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;

    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        catppuccin.catppuccin-vsc
        catppuccin.catppuccin-vsc-icons
        jnoortheen.nix-ide
        ms-azuretools.vscode-docker
        ms-vscode-remote.remote-containers
        ms-vscode-remote.remote-ssh
        ms-vscode-remote.remote-ssh-edit
        ms-vscode.remote-explorer
        redhat.vscode-yaml
        tamasfe.even-better-toml
        timonwong.shellcheck
      ];

      userSettings = {
        "editor.fontFamily" = "'JetbrainsMono Nerd Font Mono', 'monospace'";
        "editor.fontSize" = 15;
        "editor.formatOnPaste" = true;
        "editor.formatOnSave" = true;
        "editor.indentSize" = 2;
        "editor.insertSpaces" = true;
        "editor.minimap.enabled" = false;
        "editor.renderWhitespace" = "boundary";
        "editor.rulers" = [ 80 ];
        "editor.tabCompletion" = "on";
        "editor.tabSize" = 2;
        "editor.trimAutoWhitespace" = true;

        "files.autoSave" = "onFocusChange";
        "files.insertFinalNewline" = true;

        "git.autofetch" = true;

        "nix.enableLanguageServer" = true;
        "nix.formatterPath" = "alejandra";
        "nix.serverPath" = "nixd";

        "workbench.colorTheme" = "Catppuccin Mocha";
        "workbench.iconTheme" = "catppuccin-mocha";
      };
    };
  };
}
