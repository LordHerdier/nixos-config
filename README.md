# NixOS Config Layout

This repo contains my NixOS + Home Manager configuration for multiple machines (WSL and native NixOS hosts), organized around **separation of concerns**:

- **`modules/`** = reusable pieces of config (one concern each)
- **`profiles/`** = bundles of modules for a role/use-case
- **`hosts/`** = machine-specific facts and overrides

There are two parallel trees:

- **`modules/`, `hosts/`** → system-level NixOS config
- **`home/modules/`, `home/hosts/`** → user-level Home Manager config

---

## Top Level

### `flake.nix`

Main flake entrypoint.

Defines:

- flake inputs (`nixpkgs`, `home-manager`, `nixos-wsl`, dotfiles, etc.)
- host construction logic (shared `mkHost` helper)
- exported `nixosConfigurations` for each machine

This is the “wiring diagram” that connects hosts, shared modules, profiles, and Home Manager.

### `flake.lock`

Pinned input versions for reproducible builds.

---

# System Config (NixOS)

## `hosts/`

Machine-specific NixOS configuration.

Each host directory should contain only things that are truly specific to that machine:

- hostname
- hardware config import
- machine-specific networking
- host-only overrides

### `hosts/Charlie-Laptop/`

WSL host config for `Charlie-Laptop`.

- **`default.nix`**: main host entry for this machine (imports host modules/profiles)
- **`networking.nix`**: DNS/search domain settings specific to this host

### `hosts/Nico/`

WSL host config for `Nico`.

- **`default.nix`**: main host entry
- **`networking.nix`**: host-specific networking settings

### `hosts/Pine/`

Native NixOS laptop/desktop host config for `Pine`.

- **`default.nix`**: main host entry (imports hardware + profiles/features)
- **`hardware-configuration.nix`**: generated hardware config from `nixos-generate-config`
- **`networking.nix`**: host-specific networking + networkmanager setup
- **`ambxst.nix`**: host-specific Ambxst system configuration (if enabled)

---

## `modules/`

Reusable NixOS modules grouped by purpose.

### `modules/common/`

Shared baseline modules used across most or all hosts.

These are the default “foundation” settings.

- **`nix.nix`**
  Core Nix/Nixpkgs settings (flakes, experimental features, allowUnfree, etc.)

- **`packages.nix`**
  Common system packages and baseline system tooling (shell utilities, etc.)

- **`security.nix`**
  Shared security defaults (e.g. sudo policy)

- **`time.nix`**
  Shared timezone / clock settings

- **`users.nix`**
  Shared user account definitions (e.g. `charlotte`)

#### `modules/common/kmonad/`

KMonad-related config and assets.

- **`kmonad.nix`**
  KMonad service/module definition
- **`colemakHomerowMods.kbd`**
  KMonad keyboard layout/config file (Colemak + homerow mods)

---

### `modules/features/`

Optional feature modules (capabilities you opt into per host/profile).

Use these when something is **not universally applicable**.

- **`steam.nix`**
  Steam + firewall settings
- **`tailscale.nix`**
  Tailscale service and package setup

---

### `modules/profiles/`

Higher-level NixOS role bundles.

Profiles combine multiple settings/modules into a machine role (instead of repeating the same imports on each host).

- **`desktop-hyprland.nix`**
  System-level graphical desktop stack for Hyprland-based systems
  (portals, audio stack, graphics, desktop utilities, etc.)

- **`dev-docker.nix`**
  Docker development profile (Docker daemon, related settings)

- **`laptop.nix`**
  Laptop-oriented settings (e.g. bluetooth, input device support, power/laptop defaults)

- **`wsl.nix`**
  WSL-specific NixOS settings (`wsl.enable`, default user, WSL interop/resolv behavior, etc.)

- **`nixos-hardware.nix`**
  Placeholder/profile hook for hardware-related bundles (useful if adding `nixos-hardware` imports later)

---

### `modules/networking/`

Reserved space for reusable networking modules.

Use this for shared networking concerns that aren’t host-specific (VLANs, VPN helpers, firewall presets, DNS bundles, etc.).

---

# Home Manager Config (User Config)

## `home/`

User-level configuration for the `charlotte` account, managed via Home Manager.

This tree mirrors the same design principles as the system tree:

- reusable user modules
- role-based user profiles
- small host overlays

---

## `home/charlotte.nix`

Main Home Manager entrypoint for the `charlotte` user.

Defines:

- Home Manager base imports
- username/home directory/state version
- common session variables
- base user environment setup

Think of this as the root HM config for the user, not a host-specific file.

---

## `home/hosts/`

Host-specific Home Manager overlays.

These are intentionally small and should mostly:

- import one or more HM profiles
- apply minor host-only user tweaks

### `home/hosts/Charlie-Laptop.nix`

Home Manager host overlay for `Charlie-Laptop` (WSL host).

Typically imports the WSL HM profile and any host-specific user tweaks.

### `home/hosts/Nico.nix`

Home Manager host overlay for `Nico` (WSL host).

Same idea as Charlie-Laptop, but for this machine’s user environment.

### `home/hosts/Pine.nix`

Home Manager host overlay for `Pine` (native desktop).

Typically imports desktop profiles (Hyprland GUI stack, desktop dotfiles, GUI packages) and host-local user tweaks.

---

## `home/profiles/`

Home Manager role bundles.

These group user-level modules for a use-case (WSL vs desktop GUI, etc.).

- **`desktop-hyprland.nix`**
  HM profile for desktop/GUI setup on Hyprland systems
  (desktop files, desktop packages, UI-related modules)

- **`wsl.nix`**
  HM profile for WSL-specific shell/tmux/user behavior
  (WSL aliases, URL helpers, PATH additions, integration tweaks)

---

## `home/modules/`

Reusable Home Manager modules for user-level concerns.

Each file/module should ideally manage one subsystem.

### General user modules

- **`packages.nix`**
  Common user packages (CLI tools, dev tools, editors, utilities)

- **`files.nix`**
  Dotfile-managed file/symlink declarations (e.g. `~/bin`, `.oh-my-posh`, yazi config)

- **`git.nix`**
  Git config (name/email/defaults)

- **`gnupg.nix`**
  GPG + gpg-agent settings

- **`atuin.nix`**
  Atuin shell history config

- **`nvim.nix`**
  Neovim-related packages and dotfile links

- **`kitty.nix`**
  Custom Kitty terminal module (with options like enable/opacity)

- **`ambxst.nix`**
  User-level Ambxst-related cache/config file setup (wallpapers JSON, etc.)

---

### Desktop/Home UI modules

- **`desktop-files.nix`**
  Desktop-specific dotfile symlinks (Hyprland, eww, sddm, etc.)

- **`desktop-packages.nix`**
  Desktop-specific GUI packages (browser, media apps, GUI tools, etc.)

- **`hyprland/default.nix`**
  Home Manager Hyprland configuration (bindings, input, exec-once, look/feel)

---

## `home/modules/tmux/`

Tmux config split into ordered components.

This folder is intentionally chunked so each file handles one tmux concern.
`default.nix` imports the pieces.

- **`default.nix`**
  Tmux module entrypoint (enables tmux, plugins, imports all tmux submodules)

- **`00-core.nix`**
  Core tmux behavior (prefix, mouse, indexing, history, plugin defaults)

- **`10-keybinds.nix`**
  Keybindings (pane movement, window/session navigation, copy mode helpers)

- **`20-status-and-titles.nix`**
  Status bar content and terminal title behavior

- **`30-colors-kanagawa.nix`**
  Kanagawa-based color theme for tmux UI

- **`40-url-helpers.nix`**
  URL extraction/opening helpers (especially useful in WSL setups)

- **`50-smart-vim.nix`**
  Smart pane navigation/scroll behavior when switching between tmux and vim/nvim panes

> Number prefixes are used to keep a predictable merge/load order.

---

## `home/modules/zsh/`

Zsh config split by concern.

`default.nix` enables zsh and imports focused submodules.

- **`default.nix`**
  Zsh module entrypoint (enables zsh, completion, autosuggestions, syntax highlighting; imports submodules)

- **`aliases.nix`**
  Shell aliases (general CLI shortcuts/workflow aliases)

- **`profile.nix`**
  `profileExtra` content (login-shell-ish behavior like MOTD logic, environment setup)

- **`wsl.nix`**
  WSL-specific zsh additions (aliases/functions/integration only needed on WSL)

### `home/modules/zsh/init/`

Ordered interactive shell init fragments.

These are loaded in sequence to keep startup predictable and easy to debug.

- **`00-guard.nix`**
  Early guard for interactive shells only + safe shell perf options

- **`10-paths-xdg-editor.nix`**
  PATH additions, XDG env vars, default editor

- **`20-zoxide.nix`**
  Zoxide initialization

- **`30-oh-my-posh.nix`**
  Oh My Posh initialization + theme selection/loading

- **`40-ssh-agent.nix`**
  SSH agent bootstrap (including WSL-safe socket handling)

- **`50-history-completion.nix`**
  History behavior, completion matcher settings, history keybindings

- **`60-functions.nix`**
  Interactive shell functions (theme switching, helper utilities, `dumpfiles`, etc.)

- **`99-private-extras.nix`**
  Optional user-private shell snippets sourced from external files (last so they can override)

> Like tmux, numeric prefixes define order and make it obvious where new pieces belong.

---

# Design Rules (How to decide where new stuff goes)

When adding config, use this rubric:

## System-side

- **Applies to almost every machine** → `modules/common/`
- **Optional capability** (Steam, Tailscale, KMonad, etc.) → `modules/features/`
- **Role bundle** (WSL, laptop, desktop, docker-dev) → `modules/profiles/`
- **Only true for one machine** → `hosts/<name>/`

## Home Manager-side

- **One user tool/subsystem** (zsh, tmux, git, kitty) → `home/modules/`
- **User environment role** (WSL shell stack, desktop GUI stack) → `home/profiles/`
- **Tiny host-specific user overlay** → `home/hosts/<name>.nix`

---

# Naming Conventions

- `default.nix` = entrypoint for a directory/module bundle
- Numbered files (`00-`, `10-`, ...) = ordered configuration fragments
- `common` = shared baseline
- `features` = optional capability modules
- `profiles` = bundled roles/use-cases
- `hosts` = machine-specific facts and overrides

---

# Practical Notes

- **Keep host files boring** on purpose. If a host file starts getting huge, that’s usually a sign something belongs in a profile or feature module.
- **Profiles can import features**. Example: a gaming profile may import Steam + GPU tweaks.
- **Home and system profiles can mirror each other** (e.g. system `desktop-hyprland` + HM `desktop-hyprland`) without being identical — one handles OS services, the other handles user apps/dotfiles.
