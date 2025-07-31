{ pkgs }:

pkgs.mkShell {
  name = "python-shell";
  buildInputs = [
    pkgs.python3
    pkgs.python3Packages.pip
    pkgs.uv
  ];
  shellHook = ''
    echo "Python development environment loaded."
  '';
}
