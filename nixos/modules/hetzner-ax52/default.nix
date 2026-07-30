{
  imports = [
    ./disko.nix
    ./modules/network.nix
  ];

  facter.reportPath = ./facter.json;
  boot.loader.systemd-boot.enable = true;
}
