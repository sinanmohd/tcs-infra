{
  imports = [
    ../../modules/common
    ../../modules/k8s_master
    ../../modules/k8s_master_init
    ./disko.nix
  ];

  networking.hostName = "pnap";
  facter.reportPath = ./facter.json;
  bud.k8s = {
    disableLocalStorage = false;
    generateToken = true;
  };
  boot.loader.systemd-boot.enable = true;
}
