{ ... }:
{
  programs.vscode.profiles.default.userSettings = {
    "editor.acceptSuggestionOnEnter" = "smart";
    "editor.autoIndent" = "advanced";
    "editor.cursorSmoothCaretAnimation" = "on";
    "editor.find.autoFindInSelection" = "never";
    "editor.fontFamily" = "'JetbrainsMono Nerd Font Mono', 'monospace'";
    "editor.fontSize" = 15;
    "editor.formatOnPaste" = true;
    "editor.formatOnSave" = true;
    "editor.indentSize" = "tabSize";
    "editor.detectIndentation" = false;
    "editor.insertSpaces" = true;
    "editor.minimap.enabled" = false;
    "editor.renderWhitespace" = "boundary";
    "editor.rulers" = [ 80 ];
    "editor.smoothScrolling" = true;
    "editor.snippetSuggestions" = "bottom";
    "editor.tabCompletion" = "on";
    "editor.tabSize" = 2;
    "editor.trimAutoWhitespace" = true;

    "files.autoSave" = "onFocusChange";
    "files.insertFinalNewline" = true;
    "files.trimTrailingWhitespace" = true;

    "git.autofetch" = true;

    "nix.enableLanguageServer" = true;
    "nix.formatterPath" = "alejandra";
    "nix.serverPath" = "nixd";

    "update.mode" = "manual";

    "window.titleBarStyle" = "custom";

    "workbench.sideBar.location" = "right";
    "docker.extension.enableComposeLanguageServer" = true;
    "github.copilot.enable" = {
      "*" = false;
    };
    "workbench.startupEditor" = "none";
    "kilo-code.allowedCommands" = [
      "awk"
      "bash"
      "bin/vt/vm"
      "cd"
      "column"
      "cut"
      "devcontainer"
      "distrobox"
      "docker"
      "echo"
      "find"
      "git"
      "grep"
      "head"
      "ip"
      "nix"
      "nmcli"
      "podman"
      "rg"
      "sed" 
      "tail"
      "virsh"
      "virt-cat"
  ];
  "kilo-code.deniedCommands" = [
    "rm"
    "trash"
  ];  
  };
}
