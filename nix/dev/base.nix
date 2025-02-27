{ pkgs }:

pkgs.mkShell {
  name = "base-shell";
  buildInputs = [
    pkgs.trash-cli
    pkgs.gh
    pkgs.just
    pkgs.lazygit
    pkgs.eza
    pkgs.tmux
    pkgs.neovim
    pkgs.starship
    pkgs.zsh
    pkgs.delta
    pkgs.fzf
    pkgs.fd
    pkgs.zoxide
    pkgs.bat
    pkgs.ripgrep
    # pkgs.git
    # pkgs.curl
    # pkgs.wget
  ];

  shellHook = ''
    echo "shell environment loaded."
  '';
}
