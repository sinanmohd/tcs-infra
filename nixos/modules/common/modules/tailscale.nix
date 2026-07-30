{ config, ... }:
let
  headScaleUrl = "https://headscale.sinanmohd.com";
  user = config.global.userdata.name;
in
{
  networking.firewall.trustedInterfaces = [ config.services.tailscale.interfaceName ];

  services.tailscale = {
    enable = true;
    openFirewall = true;

    extraUpFlags = [
      "--login-server=${headScaleUrl}"
      "--operator=${user}"
    ];
  };
}
