{
  description = "Proxmox VM automation devshell (Zig, Rust, Nushell)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";  # you can pin if needed
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          name = "proxmox-devshell";

          buildInputs = with pkgs; [
            nixd
            nixpkgs-fmt
            statix
            zig
            rustc
            cargo
            nushell
            wget
            # Assuming you're on Proxmox where `qm` is available via system path.
            # If not, comment out the next line and install manually.
            (pkgs.writeShellScriptBin "qm" ''
              exec /usr/sbin/qm "$@"
            '')
          ];

          shellHook = ''
            echo "🔧 Proxmox automation shell loaded."
            echo "📦 Tools: Zig, Rust, Nushell, wget, qm (shim)"
          '';
        };
      }
    );
}
