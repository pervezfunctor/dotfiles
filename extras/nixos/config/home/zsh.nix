{ ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      # cd = "z";
      # gcan = "git commit --amend --no-edit";
      # gcm = "git commit -m";
      # gfm = "git pull";
      # gia = "git add";
      # gp = "git push";
      # gsa = "git stash apply";
      # gst = "git status";
      # ipa = "ip -brief a";
      # ll = "eza -l";
      # ls = "eza -a --icons=auto --group-directories-first";
      # md = "mkdir -p";
      # # pbcopy = "wl-copy";
      # pbpaste = "wl-paste --no-newline";
      # ss = "nix search nixpkgs";
      update-os = "sudo nixos-rebuild switch --flake ~/.ilm/extras/nixos/config";
    };

    initContent = ''
      source <(fzf --zsh)
      eval "$(atuin init zsh --disable-up-arrow --disable-ctrl-r)"
      export PATH=$HOME/.local/bin:$HOME/.ilm/bin:$HOME/.ilm/bin/vt:$PATH
      source $HOME/.ilm/share/utils
      source $HOME/.ilm/share/fns
      source $HOME/.ilm/share/aliases
    '';
  };
}
