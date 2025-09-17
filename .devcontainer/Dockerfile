FROM mcr.microsoft.com/devcontainers/base:ubuntu

RUN apt-get update && apt-get install -y --no-install-recommends \
  gh shellcheck shfmt zsh tmux micro ripgrep zoxide && \
  apt-get clean && rm -rf /var/lib/apt/lists/*
