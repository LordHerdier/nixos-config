# features

every file under `modules/features/` is one opt-in capability, imported
directly by whichever `hosts/<Name>/default.nix` wants it. this is the
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
- **`rdp.nix`** — gnome's built-in RDP server, headless mode, for
  productivity sessions from e.g. an iPad. **not** started automatically
  (`wantedBy` deliberately omitted): the headless backend claims
  mutter's RemoteDesktop portal the moment it runs, which starves
  sunshine of the same portal on startup. start/stop it by hand with
  `systemctl --user {start,stop} gnome-remote-desktop-headless`, and run
  `grdctl --headless rdp set-credentials/enable` once, logged in locally,
  before the first use.
- **`usbmuxd.nix`** — iphone/ipad usb pairing (libimobiledevice), so the
  "Trust This Device" prompt appears at all.

## networking & sync

- **`tailscale.nix`** — just `services.tailscale.enable`, nothing
  fancier; `open-webui.nix` and `ollama-vulkan.nix` build on top of it
  for tailnet-only exposure.
- **`syncthing.nix`** — syncs `~/documents` and `~/pictures` between
  every host that imports it (currently index and apthos). device IDs
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
- **`remote-builder.nix`** — offloads builds to the `builder` CT on twm
  (`10.0.10.8`, see [hosts.md](hosts.md#builder)) over `ssh-ng`, with
  `builders-use-substitutes` so the builder fetches from the cache itself.
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
  tuned sysctls (`swappiness=180`, `page-cluster=0`) because the
  disk-swap defaults are far too conservative for something this fast.
  no disk swap exists on these machines at all.
- **`nix-ld.nix`** — lets dynamically-linked non-nix binaries run.
- **`qylock.nix`** — sddm + the qylock quickshell theme (`clockwork/orbital`),
  index only.
- **`systemd-boot-silent/`** — quiet boot (credit: `smravec/nixos-config`).
  imported but currently disabled (commented out) on index; active on
  pine.

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
`features/`) because it's about *which physical keyboard* a host has,
not an opt-in capability — see the top-level README's keyboard section
for the layer design.
