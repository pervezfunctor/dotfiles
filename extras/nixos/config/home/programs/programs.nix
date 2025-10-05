{ vars, ... }:

{
  programs = {
    gpg.enable = true;

    # emacs.enable = true;
    nushell.enable = true;
    tmux.enable = true;
    yazi.enable = true;

    git = {
      enable = true;
      userName = "${vars.gitUserName}";
      userEmail = "${vars.gitUserEmail}";
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
    };

    atuin = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
      flags = [
        "--disable-up-arrow"
        "--disable-ctrl-r"
      ];
    };

    bat.enable = true;
    carapace.enable = true;
    direnv.enable = true;
    eza.enable = true;
    fzf.enable = true;
    zoxide.enable = true;
  };
}
