{ pkgs, ... }:
{
  imports = [
    ./shell-slim.nix
  ];

  home.packages = with pkgs; [
    atuin
    bottom
    broot
    carapace
    cheat
    choose
    curlie
    delta
    dog
    duf
    dust
    dysk
    fd
    gdu
    htop
    hyperfine
    jq
    just
    lazydocker
    lazygit
    lsd
    neovim
    nushell
    procs
    sd
    shellcheck
    shfmt
    stress-ng
    tealdeer
    xh
    yazi
    yq
  ];
}
