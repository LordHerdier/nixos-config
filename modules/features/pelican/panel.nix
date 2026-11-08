# modules/features/pelican/panel.nix — Pelican panel (web UI), as upstream's image
#
# Runs ghcr.io/pelican/panel via oci-containers on Docker (shared with
# wings.nix). The image bundles php-fpm, the queue worker, the scheduler
# and Caddy on :80. Pinned by digest.
#
# Database: SQLite under dataDir, the panel's default; no MariaDB/Redis to
# run and back up. DB_CONNECTION is pinned so the installer can't change it.
#
# Where settings live:
# - Set here, as container env: APP_URL, proxy settings, DB_CONNECTION and
#   anything in `environment`. Laravel prefers real env vars over .env, so
#   these win over whatever the panel's settings page writes.
# - <dataDir>/.env: everything else, from the settings page (mail, captcha,
#   OAuth, ...), plus APP_KEY, generated on first start, which encrypts
#   database fields. Back up dataDir, or put APP_KEY in Infisical and pass
#   it via `secretEnvVars`:
#
#     my.pelican.panel.secretEnvVars = [ "APP_KEY" ];
#     my.infisical.envFiles.pelican-panel = {
#       path = "/pelican-panel";
#       services = [ "docker-pelican-panel" ];
#     };
#
# First start: run the web installer at `url`/installer (pick SQLite).
# After that each start runs the migrations first.
#
# Upgrading: bump `image` together with pkgs/pelican-wings (panel and wings
# release in step). The digest is the multi-arch index's:
#
#   nix shell nixpkgs#skopeo -c skopeo inspect \
#     docker://ghcr.io/pelican/panel:<tag> --format '{{.Digest}}'

{
  config,
  lib,
  ...
}:

let
  cfg = config.my.pelican.panel;

  # Alpine's www-data, which the image runs as.
  wwwData = "82";
in
{
  options.my.pelican.panel = {
    url = lib.mkOption {
      type = lib.types.str;
      example = "https://panel.svc.lorscapa.com";
      description = "Public URL of the panel (APP_URL).";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 80;
      description = ''
        Host port the panel is published on, plain HTTP. TLS is terminated
        by the reverse proxy in front of it (caddy-services).
      '';
    };

    trustedProxies = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "10.0.20.249" ];
      description = ''
        Reverse proxies whose X-Forwarded-* headers the panel believes, so
        it sees real client IPs and knows it's served over HTTPS.
      '';
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/pelican-panel";
      description = ''
        Host directory mounted as the image's /pelican-data: .env (with
        APP_KEY), the SQLite database, uploads and plugins. This is what to
        back up.
      '';
    };

    image = lib.mkOption {
      type = lib.types.str;
      default = "ghcr.io/pelican/panel:v1.0.0-rc.2@sha256:cb717c15da9bcdc93f22a22a02d5460a1ce51fd03f2975b4ce53d745f4cc9ac8";
      description = "Panel image, pinned by tag and multi-arch index digest.";
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = {
        MAIL_MAILER = "smtp";
        MAIL_HOST = "smtp.example.com";
      };
      description = ''
        Extra container env. Anything set here overrides the same setting
        in the panel's settings page.
      '';
    };

    secretEnvVars = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "APP_KEY"
        "MAIL_PASSWORD"
      ];
      description = ''
        Env vars passed into the container from the docker-pelican-panel
        unit's own environment, by name, so their values never reach the
        Nix store. Fill that environment with my.infisical.envFiles (see
        this file's header).
      '';
    };
  };

  config = {
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    virtualisation.oci-containers.containers.pelican-panel = {
      inherit (cfg) image;
      ports = [ "${toString cfg.port}:80" ];
      volumes = [
        "${cfg.dataDir}:/pelican-data"
        # Same layout as upstream's compose.yml: plugins live inside the
        # data volume but are mounted where the app looks for them.
        "${cfg.dataDir}/plugins:/var/www/html/plugins"
        "/var/log/pelican-panel:/var/www/html/storage/logs"
      ];
      environment = {
        APP_URL = cfg.url;
        APP_ENV = "production";
        APP_DEBUG = "false";
        # Caddy inside the image serves plain :80 and leaves TLS to us.
        BEHIND_PROXY = "true";
        XDG_DATA_HOME = "/pelican-data";
        DB_CONNECTION = "sqlite";
      }
      // lib.optionalAttrs (cfg.trustedProxies != [ ]) {
        TRUSTED_PROXIES = lib.concatStringsSep "," cfg.trustedProxies;
      }
      // cfg.environment;
      # `-e NAME` with no value copies NAME from the docker CLI's own
      # environment, i.e. the systemd unit's.
      extraOptions = lib.concatMap (name: [
        "-e"
        name
      ]) cfg.secretEnvVars;
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0770 ${wwwData} ${wwwData} -"
      "d ${cfg.dataDir}/plugins 0770 ${wwwData} ${wwwData} -"
      "d /var/log/pelican-panel 0770 ${wwwData} ${wwwData} -"
    ];

    # Published ports go through Docker's own iptables rules, which bypass
    # the NixOS firewall, so the panel port needs no allowedTCPPorts entry.
  };
}
