# hosts/Pelican/default.nix — Pelican game panel + Wings, VM 220 on twm (Proxmox)
#
# Replaces the AMP box (192.168.50.227). Panel at
# https://pelican.svc.lorscapa.com and node API at
# https://wings.svc.lorscapa.com, both via caddy-services (LAN / tailnet
# only). Game ports are port-forwarded by OPNsense.
#
# Disks: virtio0 is the image's root disk; virtio1 is a data disk at
# /srv/pelican holding everything stateful (panel .env/APP_KEY/SQLite,
# wings' volumes and backups), so the VM can be rebuilt from a fresh image.
#
# Bring-up, in order. Steps 1-2 are on twm / in Infisical:
#
# 1. Infisical: create a `pelican` project and put its ID in
#    `infisicalProject` below. Create the folders /pelican-panel and
#    /pelican-wings in it (empty for now), and a machine identity for this
#    VM with read access to the project.
# 2. Build and restore the image (proxmox-vm.nix's header has the commands),
#    VMID 220. Then on twm:
#      qm set 220 --virtio1 local-lvm:200     # data disk, formatted on boot
#      qm disk resize 220 virtio0 32G         # root grows itself on boot
#      qm start 220
# 3. On the VM (ssh root@10.0.20.220): write /etc/infisical/service.env,
#    see docs/secrets.md. The panel won't start until this exists.
# 4. Open https://pelican.svc.lorscapa.com/installer and run the installer
#    (choose SQLite). Then copy APP_KEY from /srv/pelican/panel/.env into
#    Infisical /pelican-panel, so the key survives losing the data disk.
# 5. In the panel, create a node: FQDN wings.svc.lorscapa.com, port 443,
#    SSL, "behind proxy"; SFTP alias pelican.h.lorscapa.com, port 2022.
#    From its Configuration tab, put `uuid` in `wingsNodeUuid` below and
#    token_id/token in Infisical /pelican-wings as WINGS_TOKEN_ID and
#    WINGS_TOKEN. Redeploy: wings starts.

{
  hostName,
  lib,
  ...
}:

let
  # null until step 5; until then only the panel runs.
  wingsNodeUuid = "90ee80c9-dedc-455c-8632-6cc431eb7917";

  # Infisical project ID of the `pelican` project (step 1).
  infisicalProject = "73139db9-4682-48b6-8d71-5cb61fbd9683";

  panelUrl = "https://pelican.svc.lorscapa.com";
  caddyServices = "10.0.20.249";

  dataRoot = "/srv/pelican";
  withWings = wingsNodeUuid != null;
in
{
  imports = [
    ./networking.nix
    ../../modules/profiles/server.nix
    ../../modules/profiles/proxmox-vm.nix
    ../../modules/features/infisical-runner.nix
    ../../modules/features/pelican/panel.nix
  ]
  ++ lib.optional withWings ../../modules/features/pelican/wings.nix;

  config = lib.mkMerge (
    [
      {
        networking.hostName = lib.toLower hostName;
        system.stateVersion = "26.11";

        warnings = lib.optional (infisicalProject == "REPLACE-WITH-PELICAN-PROJECT-ID") ''
          hosts/Pelican: infisicalProject is still a placeholder, so the panel
          and wings can't fetch their secrets. See bring-up step 1.
        '';

        # Only affects the VM config embedded in the image; a live VM's
        # resources are changed with `qm set` / configure_vm.yml.
        proxmox.qemuConf = {
          cores = 4;
          memory = 16384;
          # Proxmox bridge for 10.0.20.0/24 (vmbr20); qmrestore --unique
          # gives the NIC a fresh MAC.
          net0 = "virtio=00:00:00:00:00:00,bridge=services,firewall=1";
        };

        # Data disk; autoFormat only formats a blank disk. Deliberately not
        # `nofail`: tmpfiles could then create the panel's dirs on the root
        # disk before the mount. A missing disk drops boot into the
        # emergency shell (`qm terminal 220`).
        fileSystems.${dataRoot} = {
          device = "/dev/vdb";
          fsType = "ext4";
          autoFormat = true;
        };
        systemd.services.docker-pelican-panel.unitConfig.RequiresMountsFor = [ dataRoot ];

        my.infisical = {
          projectId = infisicalProject;
          envFiles.pelican-panel = {
            path = "/pelican-panel";
            services = [ "docker-pelican-panel" ];
          };
        };

        my.pelican.panel = {
          url = panelUrl;
          dataDir = "${dataRoot}/panel";
          trustedProxies = [ caddyServices ];
          # Absent from Infisical on first boot, so the panel generates one;
          # once copied there (step 4) it's the source of truth.
          secretEnvVars = [
            "APP_KEY"
            # Proton SMTP submission token, Infisical /pelican-panel.
            "MAIL_PASSWORD"
          ];
          # Proton Mail SMTP submission. Set here, so the panel's mail
          # settings page can't override it.
          environment = {
            MAIL_MAILER = "smtp";
            MAIL_HOST = "smtp.protonmail.ch";
            MAIL_PORT = "587";
            # Plain `smtp` + port 587 = STARTTLS (Symfony upgrades and
            # verifies the cert). `smtps` would be implicit TLS, i.e. 465;
            # the panel derives smtps from MAIL_ENCRYPTION=tls, so this
            # is pinned explicitly.
            MAIL_SCHEME = "smtp";
            MAIL_USERNAME = "no-reply@lorscapa.com";
            # Proton only sends as the authenticated address.
            MAIL_FROM_ADDRESS = "no-reply@lorscapa.com";
            MAIL_FROM_NAME = "Lorscapa Pelican";
          };
        };
      }
    ]
    # Not a mkIf: my.pelican.wings only exists once wings.nix is imported.
    ++ lib.optional withWings {
      systemd.services.wings.unitConfig.RequiresMountsFor = [ dataRoot ];

      my.infisical.envFiles.wings = {
        path = "/pelican-wings";
        services = [ "wings" ];
      };

      my.pelican.wings.settings = {
        uuid = wingsNodeUuid;
        remote = panelUrl;
        api.trusted_proxies = [ caddyServices ];
        system = {
          root_directory = "${dataRoot}/wings";
          data = "${dataRoot}/wings/volumes";
          archive_directory = "${dataRoot}/wings/archives";
          backup_directory = "${dataRoot}/wings/backups";
        };
      };
    }
  );
}
