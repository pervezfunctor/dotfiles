{ config, vars, ... }:
{
  users.users.root.openssh.authorizedKeys.keys =
    config.users.users."${vars.username}".openssh.authorizedKeys.keys;
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
      #   X11Forwarding = false;
      #   AllowUsers = [
      #     "nixos"
      #     "root"
      #   ]; # Restrict SSH access
      # };
      # # Custom SSH port (optional)
      # # ports = [ 22 2222 ];
    };
  };
}
