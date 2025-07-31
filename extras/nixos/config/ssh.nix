{ config, ... }:
{
  users.users.root.openssh.authorizedKeys.keys = config.users.users.me.openssh.authorizedKeys.keys;
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };
}
