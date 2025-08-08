{ ... }:
{
  programs.bash = {
    enable = true;
    initExtra = ''
      export DOT_DIR="$HOME/.ilm"
      source "$DOT_DIR/share/bashrc"
    '';
  };
}
