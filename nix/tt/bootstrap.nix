{ pkgs ? import <nixpkgs> { } }:

pkgs.writeShellApplication {
  name = "bootstrap";
  runtimeInputs = [ pkgs.tt ];
  text = ''
    set -e

    read -p "Project description: " desc

    mkdir -p generated
    tt render ./templates/flake.tt \
      --data project-description="$desc" \
      --out ./generated

    echo "✅ flake.nix generated in ./generated/"
  '';
}
