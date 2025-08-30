{ ... }:
{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client"; # or "server" for subnet routing
    openFirewall = true;
  };
}
