# architecture

## the three layers

every nixos module in this repo is one of:

- **`modules/common/`** — applied to every host, no exceptions. users,
  nix settings (flakes, gc, auto-optimise), ssh, time zone, fonts,
  printing, security basics. small and boring on purpose.
- **`modules/features/`** — opt-in capabilities. one file, one concern:
  `tailscale.nix`, `syncthing.nix`, `steam.nix`, `sunshine.nix`,
  `ollama.nix`, `parental-controls.nix`, and so on. a host imports the
  ones it wants directly in its `default.nix`. see
  [features.md](features.md) for the full catalog.
- **`modules/profiles/`** — bundles of modules that make up a role:
  `desktop-common.nix` (audio/display-manager/polkit infra shared by
  every graphical session), `desktop-hyprland.nix` and
  `desktop-gnome.nix` (compositor-specific on top of that), `laptop.nix`
  (bluetooth, libinput), `dev-docker.nix`, `wsl.nix`. profiles compose
  modules; they don't define new capabilities themselves.

`modules/users/kiddo.nix` is a fourth, narrower category: a host-scoped
extra *system user*. It's not under `common/` because most hosts have no
business creating that account — see [kiddo.md](kiddo.md).

the home-manager side (`home/`) mirrors this: `home/modules/` is one file
per tool, `home/profiles/` bundles them into roles
(`desktop-hyprland.nix`, `desktop-gnome.nix`, `kid.nix`, `wsl.nix`), and
`home/hosts/*.nix` is the thin per-machine layer that picks a profile and
adds anything genuinely host-specific (e.g. `home/hosts/Index.nix` turns
on easyeffects; `home/hosts/Apthos.nix` pulls in the oneshot rice
modules; `home/hosts/Charlie-Laptop.nix` forces `my.theme.default` to
`kanagawa`, overriding the `oneshot` default `home/charlotte.nix` sets
for everyone else).

## `mkHost`, in `flake.nix`

every `nixosConfigurations.<Name>` is built by one function,
`mkHost { hostName, isWsl, hostPath, extraModules, extraHomeUsers }`.
what it does, in order:

1. sets `nixpkgs.hostPlatform` and registers the `overlays` that add the
   few custom packages (`concord`, `oneshot-cursors`, `oneshot-gtk-theme`,
   `oneshot-icons`, `oneshot-wallpaper`) to `pkgs`, plus one *replacement*
   — `gnome-console`, patched for an upstream bug rather than customised,
   which is why it's the one overlay entry that reads `prev`.
2. imports the five `modules/common/*.nix` files unconditionally.
3. imports `hostPath` — the host's own `default.nix` — which is where
   that host's `modules/features/*.nix` and `modules/profiles/*.nix`
   picks happen.
4. wires up `home-manager.nixosModules.home-manager`, always configuring
   a `charlotte` user from `home/charlotte.nix` + `home/hosts/<hostName>.nix`.
5. if `isWsl`, appends `nixos-wsl.nixosModules.wsl` and
   `modules/profiles/wsl.nix`.
6. appends `extraModules` (host-specific nixos modules that don't belong
   under `modules/` — index uses this for the `nixos-hardware` and
   `qylock` flake modules).
7. configures any `extraHomeUsers` — a `username -> [ home-manager
   modules ]` map, wired into `home-manager.users` *without* touching
   `home/charlotte.nix`. index is the only host that uses this, for
   `kiddo`.

`home-manager.extraSpecialArgs` hands `dotfiles`, `hostName`, `isWsl` and
`inputs` into every home-manager module — that's how e.g.
`home/charlotte.nix` knows its own hostname, and how
`home/modules/files.nix` can reach into the `dotfiles` flake input for
`bin/`, oh-my-posh themes, and yazi config.

the five `nixosConfigurations` entries at the bottom of `flake.nix` are
each a short call to `mkHost` — that's the full list of hosts this flake
knows about; see [hosts.md](hosts.md) for what each one turns on.

## adding a host

1. `hosts/<Name>/default.nix` (+ `networking.nix`, and
   `hardware-configuration.nix` if it's real/VM hardware rather than
   WSL) — import whichever `modules/features/*.nix` and
   `modules/profiles/*.nix` the host needs.
2. `home/hosts/<Name>.nix` — pick a desktop profile (or none, for a
   headless/WSL box) and add anything genuinely host-specific.
3. a `mkHost { ... }` call in `flake.nix`'s `nixosConfigurations`.

that's it — `modules/common/*.nix` and `home/charlotte.nix` apply
automatically; nothing else needs to know a new host exists.

## why the split instead of one big per-host file

a feature module and a profile are both just a NixOS/home-manager
module — the split is about where *this* module lives when you go
looking for it a year later, not a technical requirement. "is this
something literally every host wants" (`common`), "is this an opt-in
capability a host either has or doesn't" (`features`), or "is this a
bundle that defines what kind of host this is" (`profiles`) is usually
an easy call; when it isn't, `hosts/<Name>/default.nix` itself is a fine
place for the one-off.
