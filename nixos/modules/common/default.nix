{ lib, ... }:
{
  imports = [ ./modules/tailscale.nix ];

  global.userdata = {
    email = "sinan@bud.studio";
    domain = "bud.studio";
  };

  system.stateVersion = lib.mkForce "26.05";
  networking.useNetworkd = true;
  systemd.network.enable = true;
}
