# architecture

## the three layers

every nixos module in this repo is one of:

- **`modules/common/`** — the baseline. `mkHost` applies the core of it to every host: users,
  nix settings (flakes, gc, auto-optimise), time zone, packages, security
  basics. small and boring on purpose. `ssh.nix`, `fonts.nix`,
  `printing.nix` (avahi) and `kmonad/` also live here but are opt-in:
  a host imports them itself, `mkHost` does not.
- **`modules/features/`** — opt-in capabilities. one file, one concern:
  `tailscale.nix`, `syncthing.nix`, `steam.nix`, `sunshine.nix`,
  `ollama.nix`, `parental-controls.nix`, and so on. a host imports the
  ones it wants directly in its `default.nix`. see
  [features.md](features.md) for the full catalog.
- **`modules/profiles/`** — bundles of modules that make up a role:
  `desktop-common.nix` (audio/display-manager/polkit infra shared by
  every graphical session), `desktop-hyprland.nix` and
  `desktop-gnome.nix` (compositor-specific on top of that), `laptop.nix`
  (bluetooth, libinput), `dev-docker.nix`, `wsl.nix`, and the homelab
  ones: `server.nix` (headless baseline: hardened sshd, root by key for
  admin and Semaphore, python for Ansible's read-only playbooks) plus
  `proxmox-vm.nix` / `proxmox-lxc.nix` (which kind of guest on twm).
  profiles compose modules; they don't define new capabilities themselves.

`modules/users/` (`kiddo.nix`, `rivian.nix`) is a fourth, narrower category:
host-scoped extra *system users*, both index-only. They're not under
`common/` because most hosts have no business creating those accounts —
see [kiddo.md](kiddo.md).

the home-manager side (`home/`) mirrors this: `home/modules/` is one file
per tool, `home/profiles/` bundles them into roles
(`desktop-hyprland.nix`, `desktop-gnome.nix`, `kid.nix`, `wsl.nix`), and
`home/hosts/*.nix` is the thin per-machine layer that picks a profile and
adds anything genuinely host-specific (e.g. `home/hosts/Index.nix` turns
on easyeffects and forces `my.theme.default` to `halloween`;
`home/hosts/Apthos.nix` pulls in the oneshot rice
modules). the shared desktop/shell stack lives in
`home/desktop-user.nix`, which sets `my.theme.default = "kanagawa"`;
`home/charlotte.nix` and `home/rivian.nix` only add identity on top.

## `mkHost`, in `parts/hosts.nix`

`flake.nix` only declares inputs and lists the flake-parts modules in
`parts/` (`dev.nix` for the formatter and devshell, `hosts.nix` for hosts);
the overlay `mkHost` registers lives in `parts/overlay.nix`.

every `nixosConfigurations.<Name>` is built by one function,
`mkHost { hostName, isWsl, hostPath, extraModules, extraHomeUsers, withHome }`.
what it does, in order:

1. sets `nixpkgs.hostPlatform` and registers the overlay in
   `parts/overlay.nix`, which adds the custom packages to `pkgs`:
   `oneshot-cursors`, `oneshot-gtk-theme`, `oneshot-icons`,
   `oneshot-wallpaper`, `concord` (taken from its own flake), `dwl` (with
   hyprCRT's shader path), `dwl-clangd`, `slstatus` and `pelican-wings`. `gnome-console`,
   `dwl` and `slstatus` are *replacements* of nixpkgs packages (a patched
   console, a configured dwl/slstatus), which is why they read `prev`.
2. imports the five `modules/common/*.nix` files that really are universal (`packages`, `security`, `time`, `users`, `nix`) unconditionally.
3. imports `hostPath` — the host's own `default.nix` — which is where
   that host's `modules/features/*.nix` and `modules/profiles/*.nix`
   picks happen.
4. unless `withHome = false` (headless servers), wires up
   `home-manager.nixosModules.home-manager`, always configuring a
   `charlotte` user from `home/charlotte.nix` + `home/hosts/<hostName>.nix`.
5. if `isWsl`, appends `nixos-wsl.nixosModules.wsl` and
   `modules/profiles/wsl.nix`.
6. appends `extraModules` (host-specific nixos modules that don't belong
   under `modules/` — index uses this for the `nixos-hardware` and
   `qylock` flake modules).
7. configures any `extraHomeUsers` — a `username -> [ home-manager
   modules ]` map, wired into `home-manager.users` *without* touching
   `home/charlotte.nix`. index is the only host that uses this, for
   `kiddo` (the separate kid profile) and `rivian` (the same
   `home/desktop-user.nix` stack as charlotte, plus `home/hosts/Index.nix`).

`home-manager.extraSpecialArgs` hands `dotfiles`, `hostName`, `isWsl` and
`inputs` into every home-manager module — that's how e.g.
`home/charlotte.nix` knows its own hostname, and how
`home/modules/files.nix` can reach into the `dotfiles` flake input for
`bin/`, oh-my-posh themes, and yazi config.

the `nixosConfigurations` at the bottom of `parts/hosts.nix` are eight short
calls to `mkHost` (`Pelican` and `Builder` with `withHome = false`) — that's the full list of
hosts this flake knows about; see [hosts.md](hosts.md) for what each one turns on.

## adding a host

1. `hosts/<Name>/default.nix` (+ `networking.nix`, and
   `hardware-configuration.nix` if it's real/VM hardware rather than
   WSL) — import whichever `modules/features/*.nix` and
   `modules/profiles/*.nix` the host needs.
2. `home/hosts/<Name>.nix` — pick a desktop profile (or none, for a
   headless/WSL box) and add anything genuinely host-specific.
3. a `mkHost { ... }` call in `parts/hosts.nix`'s `nixosConfigurations`.

that's it — `modules/common/*.nix` and `home/charlotte.nix` apply
automatically; nothing else needs to know a new host exists.

### adding a homelab server (on twm)

1. `hosts/<Name>/default.nix` importing `modules/profiles/server.nix` and
   one of `proxmox-vm.nix` / `proxmox-lxc.nix`, plus its features. if it
   needs runtime secrets, `modules/features/infisical-runner.nix`.
2. no `home/hosts/` file — call `mkHost { ...; withHome = false; }`.
3. for a VM, build the image with
   `nix build .#nixosConfigurations.<Name>.config.system.build.VMA` and
   `qmrestore` it on twm (details in `proxmox-vm.nix`'s header).
4. in `~/documents/code/inframanagement`, add the host to its network
   group **and** the `nixos` group in `inventory/hosts.yml`. every playbook
   that changes a host excludes `nixos`, so Ansible keeps the outside of
   the guest (vm/ct, caddy routes) and this repo owns the inside.

## why the split instead of one big per-host file

a feature module and a profile are both just a NixOS/home-manager
module — the split is about where *this* module lives when you go
looking for it a year later, not a technical requirement. "is this
something literally every host wants" (`common`), "is this an opt-in
capability a host either has or doesn't" (`features`), or "is this a
bundle that defines what kind of host this is" (`profiles`) is usually
an easy call; when it isn't, `hosts/<Name>/default.nix` itself is a fine
place for the one-off.
