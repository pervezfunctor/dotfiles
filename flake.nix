{
  description = "Devcontainer environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          curl
          docker-client
          eza
          fzf
          gh
          git
          go
          jq
          micro
          neovim
          nixd
          nixfmt-rfc-style
          nodejs
          python3
          ripgrep
          shellcheck
          shfmt
          stow
          tmux
          zoxide
          zsh
        ];
      };
    };
}
