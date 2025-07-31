{
  description = "Development Environments";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      mkEnv = extraInputs: pkgs.mkShell {
        buildInputs = extraInputs;
      };

      baseEnv = import ./base.nix { inherit pkgs; };
      cppEnv = import ./cpp.nix { inherit pkgs; };
      pythonEnv = import ./python.nix { inherit pkgs; };
    in
    {
      devShells.x86_64-linux = {
        base = mkEnv baseEnv.buildInputs;
        cpp = mkEnv cppEnv.buildInputs;
        python = mkEnv pythonEnv.buildInputs;
        base-cpp = mkEnv (baseEnv.buildInputs ++ cppEnv.buildInputs);
        base-python = mkEnv (baseEnv.buildInputs ++ pythonEnv.buildInputs);
        base-cpp-python = mkEnv (baseEnv.buildInputs ++ cppEnv.buildInputs ++ pythonEnv.buildInputs);
      };
    };
}
