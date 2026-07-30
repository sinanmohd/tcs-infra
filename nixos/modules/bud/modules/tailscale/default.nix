{ config, ... }:
{
  sops.secrets."pre_auth_key".sopsFile = ./secrets.yaml;
  services.tailscale.authKeyFile = config.sops.secrets."pre_auth_key".path;
}
