{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    curl
    devenv
    devbox
    distrobox
    eza
    fzf
    gh
    git
    neovim
    nerd-fonts.jetbrains-mono
    nixd
    nixfmt-rfc-style
    ptyxis
    ripgrep
    shellcheck
    shfmt
    trash-cli
    vscode
    wget
    unzip
    zoxide
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    EDITOR = "nvim";
  };

  virtualisation.docker.enable = true;

  services.openssh.enable = true;

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than-1d";
      persistent = true;
    };
  };

  programs = {
    zsh = {
      enable = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      enableCompletion = true;

      shellAliases = { update-os = "sudo nixos-rebuild switch --flake .#"; };

      shellInit = ''
        if [[ -d "$HOME/.ilm" ]]; then
          source "$HOME/.ilm/share/utils"
          source "$HOME/.ilm/share/fns"
          source "$HOME/.ilm/share/aliases"
        fi
      '';
    };

    starship = {
      enable = true;
      interactiveOnly = true;
      transientPrompt.right = true;
    };

    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
