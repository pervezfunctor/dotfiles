{ pkgs, config, ... }:
let
  settingsFile = ./../../config/vscode/settings.json;
in
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
        redhat.vscode-yaml
        tamasfe.even-better-toml
        thenuprojectcontributors.vscode-nushell-lang
        timonwong.shellcheck
        usernamehw.errorlens
        vincaslt.highlight-matching-tag
      ];

      # Settings loaded from config/vscode/settings.json
      userSettings = builtins.fromJSON (builtins.readFile settingsFile);
    };
  };
}
