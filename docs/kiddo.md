# the kiddo account

a dedicated account for charlotte's little sister, on **index only**.
host-scoped deliberately — imported by `hosts/Index/default.nix`, not by
`modules/common/users.nix` — so the wsl hosts never grow a user that
makes no sense there.

the design is split across the system and home-manager layers, and the
split matters: none of charlotte's stack (zsh, atuin, nvf, tmux, gnupg)
leaks into her closure, and none of her gnome tuning touches charlotte's
hyprland session.

## system layer

- **`modules/users/kiddo.nix`** creates the user: `bash` not `zsh` (her
  shell has no reason to carry charlotte's prompt/history stack),
  `extraGroups = [ "video" ]` only — no `wheel` (no sudo, no rebuilds, no
  `nix-env`), not in `networkmanager` (she can see wifi status, can't
  reconfigure it). `services.gnome.games.enable` adds the
  age-appropriate GNOME games bundle (Mahjongg, Sudoku, Quadrapassel),
  and `environment.gnome.excludePackages` prunes gnome apps that are
  either redundant with charlotte's tools or an account-shaped dead end
  for a kid (Geary, Contacts, Connections, the GNOME tour).
- **`modules/features/games-mount.nix`** pre-creates
  `/mnt/games/kiddo` (0755, owned by `kiddo:users`) as her Steam library
  root — `/mnt/games` itself is group-writable by `users`, her primary
  group, so she could make this herself, but pre-making it gives "Add
  Library Folder" somewhere obvious to point at and keeps her downloads
  out of charlotte's steamapps tree.
- **`modules/features/parental-controls.nix`** turns on malcontent (the
  GNOME Settings "Parental Controls" panel). **read the scope note
  carefully before relying on this**: malcontent only gates flatpak
  installs/launches and gnome software. it does not sandbox anything
  installed through nix — whatever lands in her `home.packages` or in
  `environment.systemPackages` just runs, full stop. the real boundary
  is the package list below, not this module.
- in `hosts/Index/default.nix`, her home-manager unit
  (`systemd.services.home-manager-kiddo`) is detached from blocking boot,
  same as charlotte's, so neither user's activation holds up login.

## home-manager layer

entry point is **`home/kiddo.nix`** (not a variant of
`home/charlotte.nix` — a clean room): `home.stateVersion = "25.11"`,
imports only `home/profiles/kid.nix`.

**`home/profiles/kid.nix`** bundles five modules, each scoped to her
account:

- **`kid/packages.nix`** — her entire userland, short by design: gcompris
  (educational activities), tuxpaint (drawing), celluloid (video),
  loupe (images). the module's own header comment says it plainly —
  this list, not malcontent, is what bounds what she can run.
- **`kid/gnome.nix`** — dconf tuning for her session only. the single
  most load-bearing setting is the keyboard layout: plain `us` qwerty,
  overriding the system-wide colemak default, because a six-year-old
  learning to read cannot use colemak. **this does not defeat kmonad** —
  kmonad remaps the built-in keyboard at the evdev layer, below
  X/Wayland, and only grabs the specific `platform-i8042-serio-0-event-kbd`
  device, so an external USB keyboard would still be true qwerty
  regardless of dconf. the rest of the module is accessibility tuning for a
  six-year-old, not just preference: 1.25x text scaling and a 32px cursor
  (bigger targets, easier to read), no hot corners (an accidental trigger
  would be confusing), one fixed workspace (dynamic workspaces are the most
  common way to "lose" a window), screen lock disabled entirely (a
  locked screen mid-cartoon needs an adult to unlock it — defeats the
  point of the account), gnome search restricted away from Settings/
  Software, and dash-to-dock pinned to the bottom as a persistent,
  easy-to-hit taskbar instead of requiring the Activities overview.
- **`kid/firefox.nix`** — enterprise policies she cannot turn off from
  the UI: DuckDuckGo SafeSearch, no accounts/sync/private browsing, no
  dev tools, extension installs restricted to addons.mozilla.org only
  (so you can still add more blockers by hand later), uBlock Origin
  force-installed by policy (can't be disabled from about:addons — note
  the module's caveat that this fetches from AMO at first launch, so
  it's not offline-reproducible), homepage locked to YouTube Kids, and a
  locked, always-visible bookmarks toolbar pointing at YouTube Kids, PBS
  Kids, ABCya and Jellyfin.
- **`kid/steam.nix`** — reuses the same wrapped Steam charlotte uses
  (the extra libs there are about runtime deps, not about who's logged
  in). two things config can't express, done by hand once: sign into her
  own Steam account, and turn on Family View with a PIN.
- **`kid/desktop-entries.nix`** — two launchers wired into her gnome
  dash's favorites: "Games" (plain `steam -tenfoot`, deliberately *not*
  the gamescope session — nesting gamescope inside an existing gnome
  wayland session tends to black-screen; the full gamescope session is
  still reachable at the tuigreet login prompt under F3) and "Videos"
  (one click straight into YouTube Kids, no typing required).

## login

index runs greetd + tuigreet instead of sddm specifically so its session
picker can offer both charlotte's hyprland session and gnome (which is
where kiddo logs in) from one prompt — see `hosts/Index/default.nix` and
[hosts.md](hosts.md).

## manual steps nix can't express

- `passwd kiddo` to set a real password (the commented-out
  `initialPassword` in `modules/users/kiddo.nix` is nix-store-readable,
  fine only as a bootstrap default)
- sign into her Steam account + enable Family View with a PIN
- GNOME monitor scaling, if it ever needs touching, through Settings —
  same caveat as apthos: mutter owns `~/.config/monitors.xml` once set
