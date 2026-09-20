{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.tunnel;
in
{
  options.services.tunnel = {
    enable = mkEnableOption "Tunnel Service";

    secrets = {
      id = mkOption {
        type = types.str;
        default = "tunnel/id";
        description = "Sops secret name for tunnel ID";
      };
      secret = mkOption {
        type = types.str;
        default = "tunnel/secret";
        description = "Sops secret name for tunnel secret";
      };
      endpoint = mkOption {
        type = types.str;
        default = "tunnel/endpoint";
        description = "Sops secret name for tunnel endpoint";
      };
    };
  };

  config = mkIf cfg.enable {
    sops.secrets.${cfg.secrets.id} = {};
    sops.secrets.${cfg.secrets.secret} = {};
    sops.secrets.${cfg.secrets.endpoint} = {};

    systemd.services.launch = {
      description = "Launch Tunnel Service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.writeShellScript "launch-script" ''
          #!/bin/sh
          # Read secrets from sops files
          ID=$(cat ${config.sops.secrets.${cfg.secrets.id}.path})
          SECRET=$(cat ${config.sops.secrets.${cfg.secrets.secret}.path})
          ENDPOINT=$(cat ${config.sops.secrets.${cfg.secrets.endpoint}.path})
          
          /root/newt --id "$ID" --secret "$SECRET" --endpoint "$ENDPOINT"
        ''}";
      };
    };
  };
}
