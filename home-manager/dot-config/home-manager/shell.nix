{ pkgs, ... }:
{
  imports = [
    ./shell-slim.nix
  ];

  home.packages = with pkgs; [
    atuin
    bottom
    broot
    cheat
    choose
    curlie
    dog
    duf
    dust
    dysk
    gdu
    htop
    hyperfine
    jq
    just
    lazydocker
    lsd
    neovim
    nushell
    procs
    sd
    shellcheck
    shfmt
    stress-ng
    xh
    yq
  ];
}
