# hosts

five `nixosConfigurations`, built by the same `mkHost` function (see
[architecture.md](architecture.md)). what follows is what each one
actually turns on — the feature/profile names below are all under
`modules/` unless noted, and link to [features.md](features.md) for
detail on any one of them.

## pine

native nixos laptop. `hosts/Pine/default.nix`.

- `profiles/laptop.nix` (bluetooth, libinput) + `profiles/dev-docker.nix`
  + `profiles/desktop-hyprland.nix`
- `common/kmonad/kmonad.nix` — colemak homerow mods on the built-in
  keyboard
- `features/steam.nix`, `features/tailscale.nix`, `features/nix-ld.nix`
- `features/systemd-boot-silent/` — quiet boot
- home side: `home/profiles/desktop-hyprland.nix` only, no host-specific
  extras in `home/hosts/Pine.nix`

sddm (from `desktop-common.nix`) is the greeter here; the gamescope Steam
session shows up in its session picker automatically.

## index

native nixos laptop (framework ai 300 / amd ai 300 series). `hosts/Index/default.nix`.
the one host with two logged-in roles: charlotte's hyprland session and
a dedicated **kiddo** account running gnome — see [kiddo.md](kiddo.md)
for that whole setup.

- `profiles/laptop.nix`, `profiles/dev-docker.nix`,
  `profiles/desktop-hyprland.nix` **and** `profiles/desktop-gnome.nix`
  (both desktops coexist; gnome's sddm is force-disabled in favor of
  greetd below)
- `modules/users/kiddo.nix` + `features/parental-controls.nix`
  (malcontent)
- `common/kmonad/kmonad.nix`, `features/steam.nix`,
  `features/tailscale.nix`, `features/xwayland.nix`
- `features/fingerprint-reader.nix`, `features/gvfs.nix`,
  `features/cifs-mounts.nix`, `features/games-mount.nix`,
  `features/usbmuxd.nix`, `features/nix-ld.nix`, `features/syncthing.nix`,
  `features/zram.nix`
- `features/systemd-boot-silent/` is imported but **commented out** in
  the host file — left as a note that it was tried, not currently active
- greetd + tuigreet replaces sddm (`services.displayManager.sddm.enable
  = lib.mkForce false`), specifically so its session picker (F3) can
  offer both the default Hyprland session and the gamescope "Steam"
  session; `--remember-session` keeps whichever was picked last
- home-manager for both users runs asynchronously at boot
  (`systemd.services.home-manager-{charlotte,kiddo}.before = []`) so
  neither blocks login
- home side: `home/hosts/Index.nix` adds `home/modules/easyeffects.nix`
  (mic processing) on top of `home/profiles/desktop-hyprland.nix`;
  kiddo's home root is the separate `home/kiddo.nix` →
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
  motivated this and why `rdp.nix` is deliberately *not* auto-started
  alongside it)
- `features/rdp.nix` — gnome's RDP server in headless mode, manual/
  on-demand only, for productivity use from e.g. an iPad; fights
  sunshine for mutter's RemoteDesktop portal if both run at once, see
  that module's comments
- `features/ollama-vulkan.nix` + `features/open-webui.nix` — a local
  LLM server reachable over tailscale (`tailscale serve` fronts open-webui
  with a real cert, tailnet-only) plus a chat UI in docker
- `features/cifs-mounts.nix`, `features/windows-game-drives.nix` (ntfs
  partitions shared with a sibling Windows VM that passes through the
  same disks — never running at the same time as this VM),
  `features/tailscale.nix`, `features/syncthing.nix`
- boots via grub (not systemd-boot — it's a VM) with its serial console
  mirrored to proxmox's `serial0`, so `qm terminal <vmid>` shows boot
  output too
- autologin straight into gnome, because this box has no local keyboard
  — sunshine's user unit needs `graphical-session.target` to ever start.
  deliberately *not* `sddm.autoLogin.relogin = true` — see the host
  file's comment for the retry-storm that caused
- home side: `home/hosts/Apthos.nix` pulls in all four
  `oneshot-{cursors,gtk,icons,wallpaper}` modules — the "World Machine"
  rice described in the top-level README

## charlie-laptop

nixos-wsl. `hosts/Charlie-Laptop/default.nix`.

- `features/wsl-docker-desktop.nix` (talks to Docker Desktop on the
  Windows side), `features/syncthing.nix`, `common/ssh.nix`
- `nix-ld` on directly (not the shared feature module)
- `charlotte` added to the `kvm` group
- home side: `home/profiles/wsl.nix` only — no desktop, no kmonad (wsl
  has no raw evdev access to the host keyboard anyway)
- `home/hosts/Charlie-Laptop.nix` overrides `my.theme.default` to
  `kanagawa` (`lib.mkForce`, since `home/charlotte.nix` sets the
  `oneshot` default as a plain value) — everywhere else follows
  charlotte's `oneshot` default

## nico

nixos-wsl, minimal. `hosts/Nico/default.nix`.

- `features/wsl-docker-desktop.nix` only, plus `networking.nix`
- home side: `home/profiles/wsl.nix`, same as charlie-laptop

## what's shared vs. host-specific, at a glance

| | pine | index | apthos | charlie-laptop | nico |
|---|---|---|---|---|---|
| desktop | hyprland | hyprland + gnome | gnome | — | — |
| kmonad | yes | yes | no | no | no |
| steam | yes | yes | no (sunshine streams it instead) | no | no |
| tailscale | yes | yes | yes | no | no |
| syncthing | no | yes | yes | yes | no |
| docker | dev-docker | dev-docker | dev-docker | wsl docker-desktop | wsl docker-desktop |
| second user | no | kiddo | no | no | no |
| theme | oneshot | oneshot | oneshot | kanagawa | oneshot |
