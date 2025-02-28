{ pkgs }:

pkgs.mkShell {
  name = "cpp-shell";
  buildInputs = [
    pkgs.gcc
    pkgs.clang
    pkgs.clang-tools
    pkgs.cmake
    pkgs.gdb
    pkgs.catch2
  ];
  shellHook = ''
    echo "C++ development environment loaded."
  '';
}
