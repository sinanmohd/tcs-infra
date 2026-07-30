let
  iface = "eno1";
  privateIP = [
    "192.168.35.2/24"
    "fd00:babe:b00b::2/64"
  ];
  globalGateway = [
    "5.9.149.1"
    "fe80::1"
  ];
  globalIP = [
    "5.9.149.12/27"
    "2a01:4f8:190:3201::1337/64"
  ];
in
{
  imports = [
    ../../modules/hetzner-ax52
    ../../modules/common
    ../../modules/bud
    ../../modules/k8s_master
  ];

  networking.hostName = "bud-hetzner-ax52-1";
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
    nodeIP = "192.168.35.2,fd00:babe:b00b::2";
    flannelIface = "lan";
  };
}
