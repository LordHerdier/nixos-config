# modules/features/pelican/wings.nix — Pelican Wings (game server node daemon)
#
# Runs pkgs.pelican-wings as root next to Docker, the way upstream's
# systemd unit does. What's different from a hand install:
#
# - config.yml is generated from `my.pelican.wings.settings` and copied to
#   /etc/pelican/config.yml on every start. It's a writable copy, not a
#   store symlink, because wings rewrites it on boot and the panel can push
#   node-setting changes into it. Those pushes last until the next restart,
#   then Nix's version wins, so make node changes here and not in the panel.
# - the node token isn't in config.yml at all. Wings reads WINGS_TOKEN_ID
#   and WINGS_TOKEN from its environment instead, so the host feeds them in
#   with an EnvironmentFile, normally from Infisical:
#
#     my.infisical.envFiles.wings = {
#       path = "/pelican-wings";   # holds WINGS_TOKEN_ID and WINGS_TOKEN
#       services = [ "wings" ];
#     };
#
# - the `pelican` system user is declared here. Otherwise wings tries to
#   create it with useradd, which NixOS reverts on the next switch.
# - log rotation goes through services.logrotate. Wings' own logrotate
#   setup writes /etc/logrotate.d, which NixOS doesn't read.
#
# Getting the settings: create the node in the panel, open its
# Configuration tab, and copy `uuid` and `remote` into the host file. The
# token_id and token values go into Infisical.
#
# Firewall: the API and SFTP ports are opened here. Game server ports are
# published by Docker, whose own iptables rules bypass the NixOS firewall,
# so allocations are reachable without listing them anywhere.

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

    # Pinned to the UID wings uses inside its own container image, so files
    # under /var/lib/pelican/volumes keep the same owner across rebuilds of
    # the VM. (Wings also re-chowns them on boot, via check_permissions_on_boot.)
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
