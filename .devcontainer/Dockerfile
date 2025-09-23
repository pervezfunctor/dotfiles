FROM mcr.microsoft.com/devcontainers/base:ubuntu

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  git \
  gh \
  shellcheck \
  shfmt \
  zsh \
  tmux \
  micro \
  ripgrep \
  zoxide && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install linux \
  --extra-conf "sandbox = false" \
  --determinate \
  --init none \
  --no-confirm

ENV PATH="${PATH}:/nix/var/nix/profiles/default/bin"

RUN nix profile add \
  nixpkgs#nixd \
  nixpkgs#nixfmt-rfc-style \
  nixpkgs#alejandra \
  nixpkgs#stow \
  nixpkgs#fzf \
  nixpkgs#eza \
  nixpkgs#neovim

WORKDIR /workspace
USER vscode
