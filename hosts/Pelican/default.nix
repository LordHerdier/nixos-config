# hosts/Pelican/default.nix — Pelican game panel + Wings, VM 220 on twm (Proxmox)
#
# Replaces the AMP box (192.168.50.227). Headless: built by mkHost with
# withHome = false. Panel at https://pelican.svc.lorscapa.com and the node
# API at https://wings.svc.lorscapa.com, both through caddy-services (LAN /
# tailnet only). Game ports reach it by router port-forward via OPNsense.
#
# Disks: virtio0 is the root disk from the image; virtio1 is a separate data
# disk mounted at /srv/pelican holding everything stateful (the panel's
# .env, APP_KEY and SQLite database, wings' server volumes and backups), so
# the VM can be rebuilt from a fresh image without touching game data.
#
# Bring-up, in order. Steps 1-3 are on twm / in Infisical, before first boot:
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

  # TODO(step 1): Infisical project ID of the `pelican` project.
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

        # Data disk. autoFormat makes a fresh ext4 on first boot and leaves
        # an existing filesystem alone. Deliberately not `nofail`: that would
        # let local-fs.target (and tmpfiles, which creates the panel's dirs)
        # run before the mount and put state on the root disk. A missing disk
        # drops boot into the emergency shell, reachable with `qm terminal 220`.
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
          secretEnvVars = [ "APP_KEY" ];
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
