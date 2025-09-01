FROM nixos/nix:latest

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN addgroup --gid $USER_GID $USERNAME \
 && adduser --disabled-password --gecos "" --uid $USER_UID --gid $USER_GID $USERNAME \
 && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME \
 && chmod 0440 /etc/sudoers.d/$USERNAME

RUN mkdir -p /etc/nix \
 && echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf

USER $USERNAME
WORKDIR /workspace
