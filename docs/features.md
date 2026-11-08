# features

every file under `modules/features/` is one opt-in capability, imported
directly by whichever `hosts/<Name>/default.nix` wants it (or, for a few,
via the host's `extraModules` in `parts/hosts.nix`). this is the
catalog — grouped by what they're for, not alphabetically — with the
gotcha each one's header comment exists to warn about. see
[hosts.md](hosts.md) for which hosts import which.

## remote access & streaming

- **`sunshine.nix`** — self-hosted game-stream host for moonlight
  clients (apthos → a TV). pins the encoder to `nvenc` (vulkan-video
  encode is flaky on nvidia/linux) and builds sunshine with
  `cudaSupport = true` plus a `LD_LIBRARY_PATH` wrapper fix, because the
  nixpkgs cudaSupport postFixup otherwise clobbers whatever systemd put
  there. ships a python display-sync script (matches the TV's
  refresh/HDR to the connecting client, reverts on disconnect) and an
  independent watchdog timer, because sunshine's own revert hook
  (`global_prep_cmd`'s `undo`) is unreliable across reconnects upstream.
- **`rdp.nix`** — gnome's built-in RDP server in *system* mode (what
  Settings calls "Remote Login"), for productivity sessions from e.g. an
  iPad. runs as the unprivileged `gnome-remote-desktop` system user and
  asks GDM (`RemoteDisplayFactory`) for a brand-new session per client,
  so it never touches charlotte's autologin session that sunshine
  streams, and can be always-on. consequences: it asserts GDM is the
  display manager (apthos overrides desktop-common's SDDM), and it still
  needs one-time manual setup as root (a TLS cert/key under
  `/etc/gnome-remote-desktop/` and credentials via `grdctl --system`) —
  see the module header. the older headless user-session mode lost
  because it claimed mutter's RemoteDesktop portal and starved sunshine.
- **`usbmuxd.nix`** — iphone/ipad usb pairing (libimobiledevice), so the
  "Trust This Device" prompt appears at all.

## networking & sync

- **`tailscale.nix`** — just `services.tailscale.enable`, nothing
  fancier; `open-webui.nix` and `ollama-vulkan.nix` build on top of it
  for tailnet-only exposure.
- **`syncthing.nix`** — syncs `~/documents` and `~/Pictures` between
  hosts listed in its `allDevices` (currently index and apthos;
  charlie-laptop imports the module but has no entry, so it has no peers). device IDs
  are hardcoded per host in the module (`allDevices`), and the module
  derives each host's *peer* list by filtering out its own `hostName` —
  adding a third host means deploying there first to mint its device
  ID, fetching it via the syncthing REST API (see
  [secrets.md](secrets.md) for the auth key), then adding it here and
  redeploying everywhere. GUI is localhost-only by design; reach it with
  `ssh -L 8384:localhost:8384`.
- **`cifs-mounts.nix`** — on-demand automounts of the home NAS's
  `Share`/`Media` SMB shares. credentials live outside the nix store at
  `/etc/nixos-secrets/smb-creds` — see [secrets.md](secrets.md).
- **`windows-game-drives.nix`** — NTFS partitions shared with a sibling
  Windows VM on the same proxmox host (apthos-only); safe only because
  the two VMs pass through the same disks and are never powered on
  together.
- **`games-mount.nix`** — the dedicated `/mnt/games` ext4 partition
  (index), pre-seeded with a `kiddo`-owned subdirectory so Steam's "Add
  Library Folder" has somewhere obvious to point at for her account.

## homelab

- **`infisical-runner.nix`** — nixos port of inframanagement's
  `infisical_runner.yml`: the same `/etc/infisical/service.env` →
  `infisical-refresh` → `/run/infisical/token` (hourly timer) →
  `infisical-run <cmd>` chain, against the same infisical (10.0.10.5).
  per-host `my.infisical.projectId` (no default, like the ansible
  host_vars). `my.infisical.envFiles.<name> = { path; services; }` exports
  an infisical folder to `/run/infisical/env/<name>.env` and wires it in as
  those services' `EnvironmentFile`, re-exported on every service (re)start.
  the credentials file is written by hand once per host — see
  [secrets.md](secrets.md#infisical-homelab-servers).
- **`pelican/`** — the Pelican game server panel and its node daemon,
  replacing the old AMP box. importing the directory gets both; a
  panel-only or node-only host imports `panel.nix` or `wings.nix`.
- **`pelican/panel.nix`** — upstream's `ghcr.io/pelican/panel` image
  (pinned by digest) through `virtualisation.oci-containers` on the same
  docker daemon as wings. it bundles php-fpm, the queue worker, the
  scheduler and caddy on :80, published on `my.pelican.panel.port` for
  caddy-services to proxy (`BEHIND_PROXY`, `trustedProxies`). database is
  SQLite, pinned with `DB_CONNECTION`. everything lives in
  `my.pelican.panel.dataDir` (`/var/lib/pelican-panel`): the panel's own
  `.env` (settings page edits, and `APP_KEY`, which must be backed up or
  kept in infisical via `secretEnvVars`), the database and plugins. container
  env set here overrides the settings page. first start: run the web
  installer at `<url>/installer`, choosing SQLite.
- **`pelican/wings.nix`** — the node daemon, Wings.
  `pkgs/pelican-wings` builds it from source, since it isn't
  in nixpkgs. `my.pelican.wings.settings` is the node's `config.yml`
  (`uuid` and `remote` are required, copied from the panel's node
  Configuration tab), written to `/etc/pelican/config.yml` on every start.
  config pushes from the panel are refused (`ignore_panel_config_updates`),
  so node settings are changed here, not in the panel's UI. the node
  token stays out of the store and comes in as `WINGS_TOKEN_ID`/`WINGS_TOKEN`
  through `my.infisical.envFiles`. it also turns on docker, declares the
  `pelican` user (uid 988, so wings never runs `useradd`), rotates its log
  through `services.logrotate` and opens the API (8080) and SFTP (2022)
  ports. game ports are published by docker and bypass the nixos
  firewall.

## gaming

- **`steam.nix`** — `programs.steam`, remote play, dedicated server, and
  a `gamescopeSession` registering a console-style "Steam" wayland
  session (`gamescope --steam -- steam -tenfoot -pipewire-dmabuf`),
  realtime-scheduled and VRR-aware. a greeter has to explicitly list it
  to offer it — sddm does automatically, greetd/tuigreet needs pointing
  at the session dir (see index's host file).
- **`fingerprint-reader.nix`** — fprintd + the goodix TOD driver, for
  sudo/login/polkit auth. the udev autosuspend fix only matters because
  systemd's own hwdb leaves `power/control` at `auto` for this device;
  deliberately doesn't add the driver package's own udev rules file,
  since its vendor/product match (a different goodix model) is inert
  for this hardware and only produces warnings.

## compute / AI

- **`ollama.nix`** — local LLM server tuned for the framework
  13/index's Radeon 890M (ROCm, `gfx1150`, one model loaded at a time).
  not currently imported by any host; kept for when it's wanted on index.
- **`ollama-vulkan.nix`** — the apthos variant: vulkan-accelerated
  instead of CUDA, specifically because `ollama-cuda` would have to
  compile llama.cpp from scratch locally (unfree CUDA builds aren't
  cached on hydra), while vulkan is free software and prebuilt. listens
  on all interfaces but is firewalled to `tailscale0` and `docker0`
  only — the latter because open-webui reaches it over the docker
  bridge, which isn't loopback and isn't trusted implicitly.
- **`open-webui.nix`** — chat UI for the above, in docker, bound to
  `127.0.0.1` only and fronted by `tailscale serve` for a real HTTPS
  cert, tailnet-only. the secret that signs session cookies is generated
  once into `/opt/open-webui/webui-secret.env`, outside the
  world-readable nix store.
- **`builder-cache.nix`** — uses the `builder` CT on twm
  (`10.0.10.8:5000`, see [hosts.md](hosts.md#builder)) as a binary cache
  ahead of cache.nixos.org, so anything the builder's ci has already
  built is a download. on every `mkHost` host (pine and index get it via
  `remote-builder.nix`). `connect-timeout = 5` so a machine
  that can't reach `10.0.10.0/24` (off the lan, wsl without a route) falls
  through to cache.nixos.org quickly instead of hanging.
- **`remote-builder.nix`** — imports the cache module and also offloads
  builds to the builder over `ssh-ng`, with `builders-use-substitutes` so
  the builder fetches from cache.nixos.org itself. only on pine and index.
  needs a root-only private key at `/etc/nix/builder_ed25519` on the client
  (not in the repo; the public half is authorised in
  `hosts/Builder/default.nix`). the builder's host key is pinned in
  `programs.ssh.knownHosts`. if the builder is unreachable, nix builds
  locally.

## desktop infrastructure

these aren't under `modules/profiles/` because they're genuinely opt-in
per host, not part of a "what kind of desktop is this" bundle:

- **`xwayland.nix`** — X11 app support under hyprland, plus `xrandr` for
  apps (browsers, screen-share pickers) that shell out to it to query
  monitor geometry.
- **`gvfs.nix`** — virtual filesystem support (needed for nautilus/thunar
  to browse mtp devices, archives, etc).
- **`zram.nix`** — compressed swap in RAM, `zstd`, capped at 50% of RAM;
  tuned sysctls (`swappiness=180`, `page-cluster=0`, plus
  `watermark_boost_factor=0` / `watermark_scale_factor=125`) because the
  disk-swap defaults are far too conservative for something this fast.
  no disk swap exists on these machines at all.
- **`nix-ld.nix`** — lets dynamically-linked non-nix binaries run.
- **`qylock.nix`** — the qylock quickshell lock screen (`clockwork/orbital`),
  plus sddm. index only, and imported from `parts/hosts.nix`'s
  `extraModules` rather than the host file. index force-disables sddm in
  favor of greetd, so what's live there is the lock screen: `qylock-lock`,
  which dwl binds to Super+L.
- **`dwl/`** — dwl as a second login session next to hyprland, picked from
  tuigreet's F3 list. index only, also via `extraModules`. the compositor
  itself (config.h, patch stack) is `pkgs/dwl`, documented in
  [`pkgs/dwl/README.md`](../pkgs/dwl/README.md), and its bar's status line
  is `pkgs/slstatus`. this module holds the session entry, `dwl-startup`,
  the `dwl-session` systemd target, the `dwl-*` helper scripts behind the
  popups, mako and portal routing; colours come from charlotte's
  `my.theme`. its terminal is `st-wl` (`pkgs/st-wl`, the Wayland st
  with this repo's config.h/patches.h), rebuilt for the active palette
  rather than recoloured live. image previews in the popups use st-wl's
  `icat-mini`. gotchas: it needs the desktop-hyprland profile for the
  wofi it launches, and if hyprland is already running on another
  VT, `dwl-startup` leaves the shared systemd user services
  (`graphical-session.target`, portals) alone, so the two sessions don't
  stop each other's.
- **`systemd-boot-silent/`** — quiet boot (credit: `smravec/nixos-config`).
  imported but currently disabled (commented out) on index; active on
  pine.

## hardware workarounds

- **`librepods.nix`** — LibrePods (AirPods ANC/transparency control, ear
  detection, battery) outside Apple's ecosystem. uses the harveywuk fork
  (the airpods noctalia plugin needs its status file and verbs), adds
  charlotte to the `librepods` group, and overrides `QT_STYLE_OVERRIDE`
  for the app because font-rendering.nix's value breaks its QML. a user
  service (`librepods-watch`, following BlueZ over D-Bus) starts it when a
  device with Apple's vendor ID connects and stops it 3 minutes after the
  last one disconnects. index only.
- **`framework-kmod-fix.nix`** — rebuilds `framework-laptop-kmod` with an
  install phase that runs `modules_install`, since current nixpkgs
  requires a `.ko.cer` digest the upstream package doesn't ship. drop it
  once nixpkgs fixes the package. index only.

## accounts & controls

- **`parental-controls.nix`** — enables malcontent (gnome's "Parental
  Controls" panel). scope is narrower than the name suggests: it gates
  flatpak installs/launches and gnome software only, not anything
  installed through nix. the actual containment for the kiddo account is
  her small home-manager package set — see [kiddo.md](kiddo.md).

## gui helpers referenced elsewhere

`nvidia.nix` (proprietary driver for a passed-through GPU with no
host-side driver contention) is covered under apthos in
[hosts.md](hosts.md); `kmonad.nix` lives under `modules/common/` (not
`features/`) because it's about *which physical keyboards* a host has,
not an opt-in capability — it grabs the built-in board, a generic USB
board and the Keychron K6 — see the top-level README's keyboard section
for the layer design. `wsl-docker-desktop.nix` (the WSL hosts' bridge to
Docker Desktop) is covered in [hosts.md](hosts.md).
