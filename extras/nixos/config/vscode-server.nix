{ ... }:
{
  services.code-server = {
    enable = true;
    user = "me";
    # @TODO: generate password with nix-shell -p whois --run "mkpasswd -m bcrypt"
    password = "<password>";
    # Or use
    # hashedPasswordFile = "/etc/nixos/secrets/code-server-password";
    port = 8080;
    # extraArguments = [ "--auth none" ]; # only if behind reverse proxy
  };
}
