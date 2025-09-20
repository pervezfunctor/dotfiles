{ vars, ... }:
let
  aliases = {
    hms = "nix run home-manager -- switch --flake ~/.ilm/extras/home-manager/\#${vars.username} --impure -b bak";

    # Flake configuration discovery
    "flake-configs" = "nix eval --json .#homeConfigurations --apply builtins.attrNames | jq -r '.[]'";
    "flake-show" = "nix flake show . | head -20";
    "flake-systems" = "nix eval --json . --apply 'flake: builtins.attrNames flake' | jq -r '.[]'";

    # Home Manager shortcuts
    "hm-switch" = "nix run home-manager -- switch --flake . --impure -b backup";
    "hm-build" = "nix run home-manager -- build --flake . --impure";
    "hm-diff" =
      "nix run home-manager -- build --flake . --impure && nvd diff ~/.local/state/nix/profiles/home-manager{-*-link,}";

    # Quick config switches (adjust config names as needed)
    "hm-shell" = "nix run home-manager -- switch --flake .#shell --impure -b backup";
    "hm-shell-slim" = "nix run home-manager -- switch --flake .#shell-slim --impure -b backup";
    "hm-shell-full" = "nix run home-manager -- switch --flake .#shell-full --impure -b backup";
    "hm-sys-shell" = "nix run home-manager -- switch --flake .#sys-shell --impure -b backup";

    # NixOS shortcuts (if using WSL/NixOS)
    "nos-switch" = "sudo nixos-rebuild switch --flake .";
    "nos-build" = "sudo nixos-rebuild build --flake .";
    "nos-test" = "sudo nixos-rebuild test --flake .";

    # Development and maintenance
    "flake-update" = "nix flake update";
    "flake-check" = "nix flake check";
    "flake-fmt" = "nix fmt";
    "flake-dev" = "nix develop";

    # Cleanup
    "nix-clean" = "nix-collect-garbage -d && nix store optimise";
    "hm-clean" = "nix run home-manager -- expire-generations '-7 days'";
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

in
{
  programs = {
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
      enableBashIntegration = true;
    };

    bash = {
      enable = true;
      initExtra = ''
        source ~/.ilm/share/shellrc
      '';
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
