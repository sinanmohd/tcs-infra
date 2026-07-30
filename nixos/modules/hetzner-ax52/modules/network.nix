{ config, lib, ... }:
let
  vlanId = 4000;
  vlanInterface = "lan";
  cfg = config.bud.hetzner;
in
{
  options.bud.hetzner = {
    iface = lib.mkOption {
      type = lib.types.str;
      default = null;
      description = "Network interface name";
    };
    globalGateway = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = null;
      description = "Public Gateways";
    };
    globalIP = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = null;
      description = "Public IP addresses";
    };
    privateIP = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = null;
      description = "Private IP address";
    };
  };

  config = {
    systemd.network = {
      enable = true;
      netdevs."20-vlan" = {
        netdevConfig = {
          Kind = "vlan";
          Name = vlanInterface;
          MTUBytes = 1400;
        };
        vlanConfig.Id = vlanId;
      };
      networks = {
        "30-${cfg.iface}" = {
          matchConfig.Name = cfg.iface;
          networkConfig.VLAN = vlanInterface;
          linkConfig.RequiredForOnline = "routable";
          networkConfig = {
            Address = cfg.globalIP;
            Gateway = cfg.globalGateway;
          };
        };
        "30-${vlanInterface}" = {
          matchConfig.Name = vlanInterface;
          linkConfig.RequiredForOnline = "routable";
          networkConfig.Address = cfg.privateIP;
        };
      };
    };
  };
}
