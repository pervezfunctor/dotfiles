{ pkgs }:

pkgs.mkShell {
  name = "rust-shell";
  buildInputs = [
    pkgs.rustc
    pkgs.cargo
    pkgs.rustfmt
    pkgs.rust-analyzer
    pkgs.clippy
    pkgs.rustup
  ];

  shellHook = ''
    echo "Rust development environment loaded."
  '';
}
