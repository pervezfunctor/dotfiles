{ vars, ... }:
let
  aliases = {
    hms =
      "nix run home-manager -- switch --flake ~/.ilm/home-manager/dot-config/home-manager#${vars.username} --impure -b bak";
  };

  initContent = ''
    if [[ -d "$HOME/.ilm" ]]; then
      export PATH="$HOME/.volta/bin:$HOME/.local/bin:$HOME/.ilm/bin:$HOME/.ilm/bin/vt:$PATH"

      source "$HOME/.ilm/share/utils"
      source "$HOME/.ilm/share/fns"
      source "$HOME/.ilm/share/aliases"
      source "$HOME/.ilm/share/exports"
    fi
  '';

in {
  programs = {
    home-manager.enable = true;

    eza.enable = true;
    fzf.enable = true;
    zoxide.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      shellAliases = aliases;
      initContent = initContent;
    };
  };
}
