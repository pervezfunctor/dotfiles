{ ... }:
{
  programs = {
    git = {
      enable = true;
      # @TODO: Change these values
      userName = "Pervez Iqbal";
      userEmail = "pervezfunctor@gmail.com";
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

    bash.enable = true;
    bat.enable = true;
    carapace.enable = true;
    direnv.enable = true;
    eza.enable = true;
    fzf.enable = true;
    zoxide.enable = true;
  };
}
