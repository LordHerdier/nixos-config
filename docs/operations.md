# operations

## rebuilding

```sh
# rebuild the current machine
sudo nixos-rebuild switch --flake /etc/nixos#$(hostname)

# rebuild a different host (e.g. testing a change before deploying)
sudo nixos-rebuild switch --flake /etc/nixos#Index
```

the eight valid targets are the `nixosConfigurations` names in
`parts/hosts.nix`: `Pine`, `Index`, `Apthos`, `Charlie-Laptop`, `Nico`, `Work-Laptop`,
`Pelican`, `Builder` — see [hosts.md](hosts.md). the two servers are deployed
remotely: `nh os switch --target-host root@<ip> -H <Name> /etc/nixos`.

`nix.settings.warn-dirty = false` (`modules/common/nix.nix`) means
`nixos-rebuild` won't nag about uncommitted changes — useful for
iterating, but it also means nothing will remind you to actually commit
before walking away.

## updating flake inputs

```sh
# everything
sudo nix flake update --flake /etc/nixos

# one input at a time (lower blast radius; preferred for the personal
# flakes, since they're singly-maintained and can break without warning)
sudo nix flake update dotfiles --flake /etc/nixos
sudo nix flake update noctalia --flake /etc/nixos
```

two inputs are worth extra care on update:

- **`spicetify-nix`** (`home/modules/spicetify.nix`) — the patched
  spotify build records the spotify version it was built against, so
  this input and `nixpkgs` need to move roughly together. a mismatch
  shows up as a blank/broken spotify window at runtime, not as an eval
  failure — if spotify stops rendering after an update, check this
  first.
- **`noctalia`** (`home/modules/noctalia.nix`) — `checkConfig` (on by
  default) runs `noctalia config validate` against the declared config
  at *build* time, so an incompatible key fails the build rather than
  silently doing nothing — but only for keys noctalia still recognizes.
  a version bump that renames or restructures settings can still land
  silently; re-read the module's migration notes at the bottom of the
  file after a noctalia major-version bump.

## adding a host

see [architecture.md](architecture.md#adding-a-host).

## known in-flight work

- **hyprland hyprlang → lua migration**: landed and verified on index
  (2026-10-17); the migration notes file has since been deleted.
  **pine imports the same `desktop-hyprland.nix` profile — confirm it
  has been through a logout/login since.** hyprland picks its config
  format once at startup and never re-checks, so a session started
  before the switch keeps running the old format in memory until its
  next logout, at which point it picks up lua automatically. don't
  `hyprctl reload` expecting the new config to take — that only
  regenerates a stub `hyprland.conf` and leaves the session looking
  unconfigured; a real logout is required.
- **index's `systemd-boot-silent`** is imported in
  `hosts/Index/default.nix` but commented out — tried, not currently
  active. pine has it live.
- **noctalia's own duplicate idle management**
  (`home/modules/noctalia.nix`, bottom): both noctalia's `[idle]` block
  (ported from a live v4 setting, locks at 600s via qylock) and
  `home/modules/hyprland/hypridle.nix` (locks at 300s) are enabled
  simultaneously. this predates the v4→v5 port, not introduced by it.
  hypridle is the one this repo documents as the intended owner; the
  fix is setting both of noctalia's `idle.behavior.*.enabled` to `false`
  — not yet done.

## troubleshooting

- **RDP connects but hangs at handover, or the RDP session comes up
  broken** — `rdp.nix` runs gnome-remote-desktop in *system* mode and
  depends on GDM's `RemoteDisplayFactory`; check that GDM (not SDDM) is
  the live display manager, that the system daemon is up
  (`systemctl status gnome-remote-desktop`), and that the one-time TLS
  cert/credentials from the module header were set
  (`grdctl --system status --show-credentials`). it is always on, so it
  no longer competes with sunshine for mutter's portal the way the old
  headless user-session mode did; if sunshine itself stalls on startup,
  look at sunshine, not RDP. the module header also flags an untested
  caveat about a remote login as charlotte while her autologin session
  is up.
- **sunshine's picture is black but input works** — almost always the
  CUDA/NVENC wrapper regressing after a `sunshine`/nixpkgs bump; see the
  long comment in `sunshine.nix` about `SUNSHINE_BUILD_CUDA` and
  `libcuda.so.1` not being on the default loader path. confirm with
  `journalctl --user -u sunshine` for `sws_scale`/"Invalid argument" or
  "Cannot load libcuda.so.1" errors.
- **apthos's display didn't revert after a moonlight session ended** —
  the watchdog timer (`apthos-display-watchdog`, in `sunshine.nix`)
  polls every minute and should self-heal within that window; if it
  hasn't, check `systemctl --user status apthos-display-watchdog`.
- **ollama unreachable from open-webui, but reachable from the host
  itself** — check the firewall rule on the `docker0` interface
  specifically, in `ollama-vulkan.nix`. traffic from a docker container
  arrives on `docker0`, a real interface, not loopback — loopback is
  trusted implicitly by the nixos firewall, `docker0` is not, and the
  symptom is a connection that works with `curl` from the host but not
  from inside the open-webui container.
- **a kmonad-managed keyboard isn't remapping** — check
  `systemctl status kmonad-<board>.service`; `modules/common/kmonad/kmonad.nix`
  grants charlotte passwordless start/stop/restart on these units via
  polkit specifically so this is diagnosable without sudo.
