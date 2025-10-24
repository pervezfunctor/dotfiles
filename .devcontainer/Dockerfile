FROM debian:trixie

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  sudo \
  gnupg \
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

RUN groupadd --gid 1000 vscode && \
  useradd -s /bin/bash --uid 1000 --gid 1000 -m vscode && \
  usermod -aG sudo vscode && \
  echo "vscode ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/99-vscode && \
  chmod 0440 /etc/sudoers.d/99-vscode

RUN mkdir -p /workspace && chown -R vscode:vscode /workspace

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
