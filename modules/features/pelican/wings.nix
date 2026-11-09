# modules/features/pelican/wings.nix — Pelican Wings (game server node daemon)
#
# Runs pkgs.pelican-wings as root next to Docker, like upstream's unit.
# Differences from a hand install:
#
# - config.yml is generated from `my.pelican.wings.settings` and copied
#   (writable; wings rewrites it on boot) to /etc/pelican/config.yml on
#   every start. Panel config pushes are refused, so change node settings
#   here, not in the panel's UI.
# - the node token isn't in config.yml: wings reads WINGS_TOKEN_ID and
#   WINGS_TOKEN from an EnvironmentFile, normally from Infisical:
#
#     my.infisical.envFiles.wings = {
#       path = "/pelican-wings";   # holds WINGS_TOKEN_ID and WINGS_TOKEN
#       services = [ "wings" ];
#     };
#
# - the `pelican` user is declared here; wings would otherwise useradd it,
#   which NixOS reverts on the next switch.
# - log rotation goes through services.logrotate; wings' own writes
#   /etc/logrotate.d, which NixOS doesn't read.
#
# Settings: copy `uuid` and `remote` from the node's Configuration tab in
# the panel into the host file; token_id and token go into Infisical.
#
# Firewall: API and SFTP ports are opened here. Game ports are published by
# Docker, whose iptables rules bypass the NixOS firewall.

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.pelican.wings;
  yaml = pkgs.formats.yaml { };

  configFile = yaml.generate "wings-config.yml" cfg.settings;
  configPath = "/etc/pelican/config.yml";
in
{
  options.my.pelican.wings = {
    package = lib.mkPackageOption pkgs "pelican-wings" { };

    settings = lib.mkOption {
      description = ''
        Wings config.yml, minus the token. Anything wings understands can go
        here; the options below are only the ones that have no usable
        default. See the panel's node Configuration tab for the full shape.
      '';
      default = { };
      type = lib.types.submodule {
        freeformType = yaml.type;
        options = {
          uuid = lib.mkOption {
            type = lib.types.str;
            description = "Node UUID, from the panel's node Configuration tab.";
          };
          remote = lib.mkOption {
            type = lib.types.str;
            example = "https://panel.svc.lorscapa.com";
            description = "Panel URL that wings calls back to.";
          };
        };
      };
    };
  };

  config = {
    my.pelican.wings.settings = {
      # This file is the source of truth; otherwise panel pushes would
      # apply until the next restart.
      ignore_panel_config_updates = lib.mkDefault true;
      api = {
        host = lib.mkDefault "0.0.0.0";
        port = lib.mkDefault 8080;
        # TLS is terminated by caddy-services in front of the node, so the
        # panel's node entry uses its FQDN on 443 with "behind proxy" set.
        ssl.enabled = lib.mkDefault false;
      };
      system = {
        sftp.bind_port = lib.mkDefault 2022;
        enable_log_rotate = lib.mkDefault false;
      }
      # Wings reads $TZ or /etc/timezone, and NixOS has neither.
      // lib.optionalAttrs (config.time.timeZone != null) {
        timezone = lib.mkDefault config.time.timeZone;
      };
    };

    virtualisation.docker.enable = true;

    # Pinned to the UID wings uses inside its container image, so server
    # volumes keep the same owner across VM rebuilds.
    # (Wings also re-chowns them on boot, via check_permissions_on_boot.)
    users.users.pelican = {
      isSystemUser = true;
      group = "pelican";
      uid = 988;
    };
    users.groups.pelican.gid = 988;

    # Has to exist before the unit starts: it's the WorkingDirectory, which
    # systemd also applies to ExecStartPre.
    systemd.tmpfiles.rules = [ "d /etc/pelican 0755 root root -" ];

    systemd.services.wings = {
      description = "Pelican Wings daemon";
      after = [
        "docker.service"
        "network-online.target"
      ];
      requires = [ "docker.service" ];
      partOf = [ "docker.service" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      restartTriggers = [ configFile ];

      # `wings diagnostics` shells out to these.
      path = [
        config.virtualisation.docker.package
        pkgs.coreutils
      ];

      unitConfig = {
        StartLimitIntervalSec = 180;
        StartLimitBurst = 30;
      };

      serviceConfig = {
        User = "root";
        WorkingDirectory = "/etc/pelican";
        ExecStartPre = "${pkgs.coreutils}/bin/install -D -m 0600 ${configFile} ${configPath}";
        ExecStart = "${lib.getExe cfg.package} --config ${configPath}";
        Restart = "on-failure";
        RestartSec = 5;
        LimitNOFILE = 4096;
      };
    };

    services.logrotate.settings.wings = {
      files = "${cfg.settings.system.log_directory or "/var/log/pelican"}/wings.log";
      size = "10M";
      rotate = 7;
      compress = true;
      delaycompress = true;
      dateext = true;
      missingok = true;
      notifempty = true;
      postrotate = "${config.systemd.package}/bin/systemctl kill -s HUP wings.service || true";
    };

    networking.firewall.allowedTCPPorts = [
      cfg.settings.api.port
      cfg.settings.system.sftp.bind_port
    ];
  };
}
