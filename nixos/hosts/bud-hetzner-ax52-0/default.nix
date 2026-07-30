let
  iface = "eno1";
  privateIP = [
    "192.168.35.1/24"
    "fd00:babe:b00b::1/64"
  ];
  globalGateway = [
    "157.90.141.129"
    "fe80::1"
  ];
  globalIP = [
    "157.90.141.163/26"
    "2a01:4f8:2220:3819::1337/64"
  ];
in
{
  imports = [
    ../../modules/hetzner-ax52
    ../../modules/common
    ../../modules/bud
    ../../modules/k8s_master
    ../../modules/k8s_master_init
  ];

  networking.hostName = "bud-hetzner-ax52-0";
  bud.hetzner = {
    inherit
      globalGateway
      globalIP
      privateIP
      iface
      ;
  };

  bud.k8s = {
    primaryIP = "192.168.35.1";
    nodeIP = "192.168.35.1,fd00:babe:b00b::1";
    flannelIface = "lan";
  };
}
