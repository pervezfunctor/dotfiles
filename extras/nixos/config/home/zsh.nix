{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      # cd = "z";
      md = "mkdir -p";
      ls = "eza -a --icons=auto --group-directories-first";
      ll = "eza -l";
      ipa = "ip -brief a";
      gst = "git status";
      gfm = "git pull";
      gp = "git push";
      gcm = "git commit -m";
      gsa = "git stash apply";
      gcan = "git commit --amend --no-edit";
      pbcopy = "wl-copy";
      pbpaste = "wl-paste --no-newline";
      ss = "nix search nixpkgs";
      update-os = "sudo nixos-rebuild switch --flake ~/.ilm/extras/nixos/config";
    };

    initContent = ''
      source <(fzf --zsh)
      eval "$(atuin init zsh --disable-up-arrow --disable-ctrl-r)"
      export PATH=$HOME/.local/bin:$HOME/.ilm/bin:$HOME/.ilm/bin/vt:$PATH
    '';
  };
}
