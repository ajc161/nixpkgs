{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.blocky;
  blocky = pkgs.blocky;
  format = pkgs.formats.yaml { };
  configFile = format.generate "config.yaml" cfg.settings;
in
{
  options.services.blocky = {
    enable = mkEnableOption "Fast and lightweight DNS proxy as ad-blocker for local network with many features";

    settings = mkOption {
      type = format.type;
      default = { };
      description = ''
        Blocky configuration. Refer to
        <link xlink:href="https://0xerr0r.github.io/blocky/configuration/"/>
        for details on supported values.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.services.blocky = {
      description = "A DNS proxy and ad-blocker for the local network";
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ blocky ];

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${blocky}/bin/blocky --config ${configFile}";
        Restart = "on-failure";
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
      };
    };
  };
}
