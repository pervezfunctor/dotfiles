{ pkgs, ... }:

{
  hostName = "7945hx"; # unique name for this machine, used in the hostname and SSH config.
  userName = "pervez"; # This user will have sudo access.

  gitUserName = "Pervez Iqbal"; # git config user.name
  gitUserEmail = "pervezfunctor@gmail.com"; # git config user.email

  # Copy your SSH public key here; you can generate it with `ssh-keygen -t ed25519`
  # You can also use `ssh-add ~/.ssh/id_ed25519` to add the key to the agent.
  # rsa key is fine too, but ed25519 is preferred.
  sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIcXIDK5n+AIXExMo9nt1PRGcowyvyZUPvhBGRJRGMAl me@fedora";

  # Set the initial password for the user; you MUST change it later.
  initialPassword = "nixos";

  shell = pkgs.zsh;
  # generate password with nix-shell -p whois --run "mkpasswd -m bcrypt"
  vscodeServer.password = "vscode-server-password";

  # THIS IS DANGEROUS. All data on this disk will be lost.
  diskoMainDisk = "/dev/nvme0n1";
  diskoSwapSize = "8G";

  # networking.interfaces.enp1s0.useDHCP = true;
}
