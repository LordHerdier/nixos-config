# modules/features/infisical-runner.nix — Infisical token refresh + secret injection
#
# NixOS port of inframanagement's playbooks/deployment/infisical_runner.yml,
# pulling runtime secrets from the same Infisical (10.0.10.5) as the
# Ansible-managed fleet. Same shape:
#
#   /etc/infisical/service.env   machine-identity credentials, written by hand
#                                (the Ansible Vault step's equivalent; see below)
#   infisical-refresh            universal-auth login -> /run/infisical/token
#   infisical-token.timer        refreshes at boot+10s, then hourly
#   infisical-run <cmd>          `infisical run` with the token, refreshing it
#                                first if it's over 50 minutes old
#
# Plus `my.infisical.envFiles`: exports a secrets folder to a dotenv file
# under /run before a service starts and sets it as that service's
# EnvironmentFile. Re-exported on every (re)start.
#
# Bootstrap, once per host (the bit Ansible Vault does for other hosts):
#   1. create a machine identity for the host in Infisical, with access to
#      `my.infisical.projectId`
#   2. on the host:
#        install -d -m 0750 /etc/infisical
#        install -m 0600 /dev/stdin /etc/infisical/service.env <<EOF
#        INFISICAL_CLIENT_ID=...
#        INFISICAL_CLIENT_SECRET=...
#        EOF
#   3. systemctl start infisical-token && infisical-run env | grep -c .
#
# OPNsense's documented intent only allows DNS/NTP from vmbr20 into infra,
# but 10.0.10.5:8080 is reachable in practice (authentik, actual, ... on
# vmbr20 already use it).

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.infisical;

  runDir = "/run/infisical";
  tokenFile = "${runDir}/token";
  envDir = "${runDir}/env";

  commonFlags = lib.escapeShellArgs [
    "--projectId=${cfg.projectId}"
    "--env=${cfg.env}"
    "--domain=${cfg.apiUrl}"
  ];

  infisical-refresh = pkgs.writeShellApplication {
    name = "infisical-refresh";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.infisical
    ];
    text = ''
      # shellcheck disable=SC1091
      source ${lib.escapeShellArg cfg.credentialsFile}

      install -d -m 0750 -o root -g ${cfg.group} ${runDir}

      # Write to a temp file and rename, so a failed login leaves the
      # previous (possibly still valid) token in place instead of an
      # empty file.
      tmp=$(mktemp ${runDir}/.token.XXXXXX)
      trap 'rm -f "$tmp"' EXIT
      infisical login \
        --method=universal-auth \
        --client-id="$INFISICAL_CLIENT_ID" \
        --client-secret="$INFISICAL_CLIENT_SECRET" \
        --domain=${lib.escapeShellArg cfg.apiUrl} \
        --plain --silent > "$tmp"
      chown root:${cfg.group} "$tmp"
      chmod 0640 "$tmp"
      mv "$tmp" ${tokenFile}
    '';
  };

  refreshCmd = "${infisical-refresh}/bin/infisical-refresh";

  infisical-run = pkgs.writeShellApplication {
    name = "infisical-run";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.infisical
    ];
    text = ''
      # Refresh if missing or older than 50 minutes, like the Ansible wrapper.
      if [ ! -s ${tokenFile} ] \
        || [ $(( $(date +%s) - $(stat -c %Y ${tokenFile}) )) -gt 3000 ]; then
        if [ "$(id -u)" -eq 0 ]; then
          ${refreshCmd}
        else
          /run/wrappers/bin/sudo ${refreshCmd}
        fi
      fi

      INFISICAL_TOKEN=$(cat ${tokenFile})
      export INFISICAL_TOKEN
      exec infisical run ${commonFlags} -- "$@"
    '';
  };

  envFileOpts =
    { name, ... }:
    {
      options = {
        path = lib.mkOption {
          type = lib.types.str;
          default = "/";
          example = "/pelican";
          description = "Infisical folder to export.";
        };
        services = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          example = [ "newt" ];
          description = ''
            systemd services (without `.service`) that get this file as an
            EnvironmentFile and won't start unless the export succeeds.
          '';
        };
        file = lib.mkOption {
          type = lib.types.str;
          readOnly = true;
          default = "${envDir}/${name}.env";
          description = "Where the dotenv file is written (root:root 0600).";
        };
      };
    };

  exportUnit = name: "infisical-env-${name}";
in
{
  options.my.infisical = {
    projectId = lib.mkOption {
      type = lib.types.str;
      example = "86013b30-d1de-4f10-a7ab-c07aab957b81";
      description = ''
        Infisical project to pull secrets from (Ansible's
        `infisical_project_id`). No default: each host has its own, as in
        inframanagement's host_vars.
      '';
    };
    env = lib.mkOption {
      type = lib.types.str;
      default = "prod";
      description = "Environment slug (Ansible's `infisical_env`).";
    };
    apiUrl = lib.mkOption {
      type = lib.types.str;
      default = "http://10.0.10.5:8080";
      description = "Infisical server (Ansible's `infisical_api_url`).";
    };
    credentialsFile = lib.mkOption {
      type = lib.types.str;
      default = "/etc/infisical/service.env";
      description = ''
        Root-only file defining INFISICAL_CLIENT_ID and
        INFISICAL_CLIENT_SECRET. Not managed by Nix (the store is
        world-readable); see the bootstrap steps at the top of this file.
      '';
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = "root";
      description = ''
        Group that can read the token and run infisical-refresh via
        passwordless sudo (Ansible's `infisical_runner_group`).
      '';
    };
    envFiles = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule envFileOpts);
      default = { };
      example = lib.literalExpression ''
        { newt = { path = "/newt"; services = [ "newt" ]; }; }
      '';
      description = "Secrets folders exported to dotenv files for systemd services.";
    };
  };

  config = lib.mkMerge [
    {
      environment.systemPackages = [
        pkgs.infisical
        infisical-refresh
        infisical-run
      ];

      systemd.tmpfiles.rules = [
        "d ${runDir} 0750 root ${cfg.group} -"
        "d ${envDir} 0700 root root -"
      ];

      systemd.services.infisical-token = {
        description = "Refresh Infisical token";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = refreshCmd;
        };
      };

      systemd.timers.infisical-token = {
        description = "Refresh Infisical token periodically";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "10s";
          OnUnitActiveSec = "1h";
        };
      };

      security.sudo.extraRules = lib.mkIf (cfg.group != "root") [
        {
          groups = [ cfg.group ];
          runAs = "root";
          commands = [
            {
              command = refreshCmd;
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];
    }

    {
      # One oneshot exporter per env file. No RemainAfterExit, so every
      # (re)start of a consumer re-runs it (and infisical-token) and picks
      # up rotated secrets.
      systemd.services = lib.mkMerge (
        lib.mapAttrsToList (
          name: ef:
          {
            ${exportUnit name} = {
              description = "Export Infisical secrets for ${name}";
              requires = [ "infisical-token.service" ];
              after = [ "infisical-token.service" ];
              path = [ pkgs.infisical ];
              serviceConfig = {
                Type = "oneshot";
                UMask = "0077";
              };
              script = ''
                tmp=$(mktemp ${envDir}/.${name}.XXXXXX)
                trap 'rm -f "$tmp"' EXIT
                infisical export ${commonFlags} \
                  --path=${lib.escapeShellArg ef.path} \
                  --format=dotenv --silent \
                  --token="$(cat ${tokenFile})" > "$tmp"
                mv "$tmp" ${ef.file}
              '';
            };
          }
          // lib.genAttrs ef.services (_: {
            requires = [ "${exportUnit name}.service" ];
            after = [ "${exportUnit name}.service" ];
            serviceConfig.EnvironmentFile = [ ef.file ];
          })
        ) cfg.envFiles
      );
    }
  ];
}
