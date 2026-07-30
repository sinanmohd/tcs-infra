{
  config,
  pkgs,
  lib,
  ...
}:
let
  k3sCfg = config.services.k3s;
  cfg = config.bud.k8s;
in
{
  options.bud.k8s = {
    primaryIP = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      example = "192.168.31.1";
      default = null;
    };
    nodeIP = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      example = "192.168.31.1,fe80::aa93:4aff:fe50:c8b3";
      default = null;
    };
    flannelIface = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      example = "lan";
      default = null;
    };
    disableLocalStorage = lib.mkOption {
      type = lib.types.bool;
      example = "false";
      default = true;
    };
    generateToken = lib.mkOption {
      type = lib.types.bool;
      example = "false";
      default = false;
    };
  };

  config = {
    # k3s ingress
    networking.firewall = {
      allowedTCPPorts = [
        # http ingress
        80
        443
      ];

      extraCommands =
        let
          privateCIDR4 = [
            "192.168.0.0/16"
            "10.0.0.0/8"
            "172.16.0.0/12"
          ];
          privateCIDR6 = [
            "fd00::/8"
          ];
          privateTCPPorts = [
            # HA with embedded etcd
            2379
            2380
            # K3s supervisor and Kubernetes API Server
            6443
            # Kubelet metrics
            10250
            # Spegel: k3s embedded distributed registry
            # OpenEBS: Mayastor gRPC
            10124
            # OpenEBS: NVMf
            8420
            4421
          ];
          privateUDPPorts = [
            # Flannel VXLAN
            8472
          ];

          allowCIDRPorts =
            cidrs: ports: proto: isIPv6:
            let
              cmd = if isIPv6 then "ip6tables" else "iptables";
            in
            lib.flatten (
              map (
                cidr:
                (map (
                  port:
                  "${cmd} -A nixos-fw --source ${cidr} -p ${proto} -m ${proto} --dport ${toString port} -j nixos-fw-accept"
                ) ports)
              ) cidrs
            );
        in
        lib.concatLines (
          (allowCIDRPorts privateCIDR4 privateUDPPorts "udp" false)
          ++ (allowCIDRPorts privateCIDR6 privateUDPPorts "udp" true)
          ++ (allowCIDRPorts privateCIDR4 privateTCPPorts "tcp" false)
          ++ (allowCIDRPorts privateCIDR6 privateTCPPorts "tcp" true)
        );
    };

    environment = {
      variables.KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
      systemPackages = with pkgs; [
        kubernetes-helm
        k9s
      ];
    };

    # for checkpoint/stove8s
    programs.criu.enable = true;
    environment.etc."criu/runc.conf".text = ''
      tcp-established
      link-remap
      timeout=3600
    '';
    systemd.services.k3s.path = with pkgs; [
      criu
      # kata
      kata-runtime
    ];
    systemd.tmpfiles.settings."09-k3s"."/var/lib/rancher/k3s/agent/etc/containerd/config-v3.toml.tmpl"."L+".argument =
      let
        template = ''
          {{ template "base" . }}

          [plugins.'io.containerd.cri.v1.runtime'.containerd.runtimes.'kata']
              runtime_type = "io.containerd.kata.v2"
              privileged_without_host_devices = true
              pod_annotations = ["io.katacontainers.*"]
              container_annotations = ["io.katacontainers.*"]
        '';
      in
      "${pkgs.writeText "config-v3.toml.tmpl" template}";
    systemd.services.k3s.serviceConfig.DeviceAllow = [
      "/dev/kvm rwm"
      "/dev/mshv rwm"
      "/dev/kmsg rwm"
      "/dev/vhost-vsock rwm"
      "/dev/vhost-net rwm"
      "/dev/net/tun rwm"
    ];
    systemd.services.k3s.serviceConfig.Delegate = "yes";

    boot = {
      # criu
      kernel.sysctl = {
        "kernel.io_uring_disabled" = 2;
        # openebs
        "vm.nr_hugepages" = 1024;
      };
      # openebs
      kernelParams = [ "nvme_core.multipath=Y" ];
      kernelModules = [
        "nvme_core"
        "nvme_tcp"
      ];
    };

    sops.secrets = lib.optionalAttrs (cfg.generateToken == false) {
      "k3s_server_token".sopsFile = ./secrets.yaml;
    };
    services.k3s =
      (lib.optionalAttrs (cfg.generateToken == false) {
        tokenFile = config.sops.secrets."k3s_server_token".path;
      })
      // {
        enable = true;
        gracefulNodeShutdown.enable = true;
        serverAddr = lib.optionalString (
          k3sCfg.clusterInit == false || k3sCfg.role == "agent"
        ) "https://${cfg.primaryIP}:6443";

        extraFlags =
          lib.optionals cfg.disableLocalStorage [
            "--disable local-storage"
          ]
          ++ lib.optionals (k3sCfg.clusterInit && cfg.primaryIP != null) [
            # can only enable IPv6 on fresh clusterInit
            "--cluster-cidr=10.42.0.0/16,fd12:b0d8:b00b::/56"
            "--service-cidr=10.43.0.0/16,fd12:b0d8:babe::/112"
            "--flannel-ipv6-masq"
            "--node-ip=${cfg.nodeIP}"
          ]
          ++ lib.optionals (k3sCfg.clusterInit && cfg.primaryIP != null) [
            "--tls-san=${cfg.primaryIP}"
          ]
          ++ lib.optionals (k3sCfg.role == "server") (
            [
              "--write-kubeconfig-group=users"
              "--write-kubeconfig-mode=0640"
            ]
            ++ lib.optionals (cfg.flannelIface != null) [
              "--flannel-iface=${cfg.flannelIface}"
            ]
          );

        # https://github.com/k3s-io/k3s/discussions/2997#discussioncomment-12315047
        manifests.traefik-daemonset = {
          enable = true;
          target = "traefik-daemonset.yaml";
          source = ./traefik-daemonset.yaml;
        };
      };
  };
}
