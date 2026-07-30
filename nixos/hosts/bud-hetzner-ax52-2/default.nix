let
  iface = "enp6s0";
  privateIP = [
    "192.168.35.3/24"
    "fd00:babe:b00b::3/64"
  ];
  globalGateway = [
    "138.201.124.129"
    "fe80::1"
  ];
  globalIP = [
    "138.201.124.169/26"
    "2a01:4f8:172:27ec::1337/64"
  ];
in
{
  imports = [
    ../../modules/hetzner-ax52
    ../../modules/common
    ../../modules/bud
    ../../modules/k8s_master
  ];

  networking.hostName = "bud-hetzner-ax52-2";
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
    nodeIP = "192.168.35.3,fd00:babe:b00b::3";
    flannelIface = "lan";
  };
}
