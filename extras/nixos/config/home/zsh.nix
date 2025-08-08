{ ... }:

let
  aliases = {
    update-os = "sudo nixos-rebuild switch --flake ~/.ilm/extras/nixos/config";
    upgrade-os = "sudo nixos-rebuild switch --recreate-lock-file --flake .";

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
  };

in
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = aliases;

    # Just being extra careful to not break the shell.
    initContent = ''
      if [[ -d "$HOME/.ilm" ]]; then
        export PATH="$HOME/.volta/bin:$HOME/.local/bin:$HOME/.ilm/bin:$HOME/.ilm/bin/vt:$PATH"

        source "$HOME/.ilm/share/utils"
        source "$HOME/.ilm/share/fns"
        source "$HOME/.ilm/share/aliases"
      fi
    '';
  };
}
