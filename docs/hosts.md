# hosts

seven `nixosConfigurations`, all built by the same `mkHost` function (see
[architecture.md](architecture.md)); `Builder` passes `withHome = false`. what follows is what each one
actually turns on — the feature/profile names below are all under
`modules/` unless noted, and link to [features.md](features.md) for
detail on any one of them.

## pine

native nixos laptop. `hosts/Pine/default.nix`.

- `profiles/laptop.nix` (bluetooth, libinput) + `profiles/dev-docker.nix`
  + `profiles/desktop-hyprland.nix`
- `common/kmonad/kmonad.nix` — colemak homerow mods on the built-in
  keyboard
- `features/steam.nix`, `features/tailscale.nix`, `features/nix-ld.nix`,
  `features/remote-builder.nix` (offloads builds to the builder)
- `features/systemd-boot-silent/` — quiet boot
- home side: `home/profiles/desktop-hyprland.nix` only, no host-specific
  extras in `home/hosts/Pine.nix`

sddm (from `desktop-common.nix`) is the greeter here; the gamescope Steam
session shows up in its session picker automatically.

## index

native nixos laptop (framework ai 300 / amd ai 300 series). `hosts/Index/default.nix`.
the one host with two logged-in roles: charlotte's hyprland (or dwl) session and
a dedicated **kiddo** account running gnome — see [kiddo.md](kiddo.md)
for that whole setup — and a third, **rivian**, an admin account with the same
desktop/shell stack as charlotte.

- `profiles/laptop.nix`, `profiles/dev-docker.nix`,
  `profiles/desktop-hyprland.nix` **and** `profiles/desktop-gnome.nix`
  (both desktops coexist; gnome's sddm is force-disabled in favor of
  greetd below)
- `modules/users/kiddo.nix` + `features/parental-controls.nix`
  (malcontent), `modules/users/rivian.nix`
- `common/kmonad/kmonad.nix`, `features/steam.nix`,
  `features/tailscale.nix`, `features/xwayland.nix`
- `features/fingerprint-reader.nix`, `features/gvfs.nix`,
  `features/cifs-mounts.nix`, `features/games-mount.nix`,
  `features/usbmuxd.nix`, `features/librepods.nix` (AirPods control),
  `features/nix-ld.nix`, `features/syncthing.nix`, `features/zram.nix`,
  `features/framework-kmod-fix.nix` (workaround for the framework kmod
  package missing its `.ko.cer`), `features/remote-builder.nix`,
  `common/fonts.nix`
- `features/systemd-boot-silent/` is imported but **commented out** in
  the host file — left as a note that it was tried, not currently active
- `features/qylock.nix` and `features/dwl/` come in through
  `extraModules` in `parts/hosts.nix`, not the host file. qylock is the
  lock screen; dwl is a second compositor session, see
  [`pkgs/dwl/README.md`](../pkgs/dwl/README.md)
- greetd + tuigreet replaces sddm (`services.displayManager.sddm.enable
  = lib.mkForce false`), specifically so its session picker (F3) can
  offer the default Hyprland session, dwl and the gamescope "Steam"
  session; `--remember-session` keeps whichever was picked last
- home-manager for all three users runs asynchronously at boot
  (`systemd.services.home-manager-{charlotte,rivian,kiddo}.before = []`) so
  none blocks login
- home side: `home/hosts/Index.nix` adds `home/modules/easyeffects.nix`
  (mic processing) on top of `home/profiles/desktop-hyprland.nix` and
  forces `my.theme.default` to `halloween`; rivian reuses that file via
  `extraHomeUsers` on top of `home/rivian.nix`; kiddo's home root is the separate `home/kiddo.nix` →
  `home/profiles/kid.nix` tree, nothing shared with charlotte's

## apthos

**not bare metal** — a nixos VM on a proxmox host (twm), with a gpu and
an nvme passed through. `hosts/Apthos/default.nix`.

- `profiles/desktop-gnome.nix` + `profiles/dev-docker.nix`
- `features/nvidia.nix` (proprietary driver, since the gpu is passed
  through with no host-side nouveau/nvidia contention to worry about)
- `features/sunshine.nix` — the point of this host: self-hosted game
  streaming to a TV via moonlight, including a display-sync script that
  matches the TV's mode/HDR to whatever the connecting client asked for
  and a watchdog timer that reverts it if sunshine's own undo hook
  misses (see the module's header comment for the mutter crash that
  motivated this)
- `features/rdp.nix` — gnome's RDP server in *system* mode ("Remote
  Login"), always on, for productivity use from e.g. an iPad. it runs as
  its own system service and asks GDM for a fresh remote session, so it
  never touches charlotte's autologin session that sunshine streams;
  hence the GDM requirement below. the earlier headless user-session
  mode starved sunshine of mutter's RemoteDesktop portal — the history
  is in that module's header
- `features/ollama-vulkan.nix` + `features/open-webui.nix` — a local
  LLM server reachable over tailscale (`tailscale serve` fronts open-webui
  with a real cert, tailnet-only) plus a chat UI in docker
- `features/cifs-mounts.nix`, `features/windows-game-drives.nix` (ntfs
  partitions shared with a sibling Windows VM that passes through the
  same disks — never running at the same time as this VM),
  `features/tailscale.nix`, `features/syncthing.nix`,
  `features/builder-cache.nix`, `features/steam.nix` (so steam is
  installed locally too, though sunshine is the main use),
  `common/kmonad/kmonad.nix`
- **GDM** replaces the SDDM that `desktop-common` pulls in
  (`services.displayManager.sddm.enable = lib.mkForce false`), because
  `rdp.nix` needs GDM's remote display factory; `autoSuspend = false` so
  the greeter doesn't suspend a box that's only reached remotely
- boots via grub (not systemd-boot — it's a VM) with its serial console
  mirrored to proxmox's `serial0`, so `qm terminal <vmid>` shows boot
  output too
- autologin straight into gnome, because this box has no local keyboard
  — sunshine's user unit needs `graphical-session.target` to ever start.
  autologin fires once, at boot; deliberately no auto-relogin — the host
  file's comment records the retry-storm that `relogin = true` caused
  back on SDDM
- home side: `home/hosts/Apthos.nix` pulls in all five
  `oneshot-{console,cursors,gtk,icons,wallpaper}` modules — the "World
  Machine" rice described in the top-level README

## charlie-laptop

nixos-wsl. `hosts/Charlie-Laptop/default.nix`.

- `features/wsl-docker-desktop.nix` (talks to Docker Desktop on the
  Windows side), `features/syncthing.nix` (imported, but no entry in the
  module's device list, so it has no peers yet), `features/builder-cache.nix`,
  `common/ssh.nix`
- `nix-ld` on directly (not the shared feature module)
- `charlotte` added to the `kvm` group
- home side: `home/profiles/wsl.nix` only — no desktop, no kmonad (wsl
  has no raw evdev access to the host keyboard anyway)
- `home/hosts/Charlie-Laptop.nix` also sets `my.theme.default` to
  `kanagawa` with `lib.mkForce` — redundant today, since
  `home/desktop-user.nix` already defaults to `kanagawa`

## nico

nixos-wsl, minimal. `hosts/Nico/default.nix`.

- `features/wsl-docker-desktop.nix` and `features/builder-cache.nix`, plus
  `networking.nix`
- home side: `home/profiles/wsl.nix`, same as charlie-laptop

## work-laptop

native nixos laptop, replacing the windows + wsl setup on the work
machine. `hosts/Work-Laptop/default.nix`.

- `profiles/laptop.nix` + `profiles/dev-docker.nix` +
  `profiles/desktop-hyprland.nix`, `common/ssh.nix`, `features/nix-ld.nix`,
  `features/builder-cache.nix`
- systemd-boot (uefi), networkmanager
- **`hosts/Work-Laptop/hardware-configuration.nix` is a placeholder** —
  regenerate it with `nixos-generate-config --show-hardware-config` on
  the real machine
- home side: `home/profiles/desktop-hyprland.nix`, with `my.hackyTts` turned
  off (its piper-tts dependency chain doesn't build here)

## builder

**not a workstation** — a headless nixos LXC (CT 407) on the proxmox host
twm, at `10.0.10.8` on the infra VLAN. 8 cores, 16 GiB, 120 GiB rootfs.
`hosts/Builder/default.nix`. built by `mkHost` with `withHome = false`: no
home-manager, no desktop, no `home/hosts/` file. imports
`profiles/server.nix` + `profiles/proxmox-lxc.nix`, so it gets
`modules/common/*` like every other host. in inframanagement's inventory as
`builder`, in the `infra` and `nixos` groups.

- pine and index offload builds to it via `features/remote-builder.nix`;
  all six hosts use it as a binary cache via `features/builder-cache.nix`
  (see [features.md](features.md#compute--ai))
- unprivileged container with `nesting=1`, which is what lets the nix
  build sandbox work inside it
- ssh: root (key only — charlotte's key for `--target-host`, semaphore's
  for the read-only playbooks), charlotte (key only, no sudo) and
  `nixbuild` (the user clients build as, a nix `trusted-user`)
- `min-free`/`max-free` are set so it garbage-collects mid-build rather
  than filling the 120 GiB disk
- serves its store as a signed binary cache (harmonia, port 5000)
- `hosts/Builder/ci.nix` + `ci-build.sh`: every 5 minutes it polls
  github for `main` and open PRs from this repo's own branches (never
  forks) of `LordHerdier/nixos-config` and builds all six hosts for
  any new commit (flake-lock bump PRs included), posting a
  `nixos-ci/<host>` commit status for each. every host
  pulls from the cache (`features/builder-cache.nix`); only index and pine
  also offload their own builds to it (`features/remote-builder.nix`). each
  result is a gc root, so it stays in the cache: one per host for main,
  one per host per *open* PR, dropped when the PR closes. a failed commit
  is remembered and not retried until the branch moves. logs:
  `journalctl -u nixos-ci` on the builder; state in `/var/lib/nixos-ci`
- deploy changes with
  `nixos-rebuild switch --flake /etc/nixos#Builder --target-host root@10.0.10.8`.
  it exits 4 on a failed root `dbus-broker` user-unit reload — harmless in
  an LXC; the system is switched

## what's shared vs. host-specific, at a glance

| | pine | index | apthos | charlie-laptop | nico | work-laptop |
|---|---|---|---|---|---|---|
| desktop | hyprland | hyprland + gnome | gnome | — | — | hyprland |
| kmonad | yes | yes | yes | no | no | no |
| steam | yes | yes | yes (alongside sunshine) | no | no | no |
| tailscale | yes | yes | yes | no | no | no |
| syncthing | no | yes | yes | yes | no | no |
| docker | dev-docker | dev-docker | dev-docker | wsl docker-desktop | wsl docker-desktop | dev-docker |
| extra users | no | kiddo, rivian | no | no | no | no |
| theme | kanagawa | halloween | kanagawa (gtk rice: oneshot) | kanagawa | kanagawa | kanagawa |
