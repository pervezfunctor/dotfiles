{ pkgs }:

pkgs.mkShell {
  name = "base-shell";
  buildInputs = [
    # pkgs.git
    # pkgs.curl
    # pkgs.wget
  ];

  shellHook = ''
    echo "shell environment loaded."
  '';
}
