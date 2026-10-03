# nixos config

> nix flakes + home-manager configuration for four machines

---

## hosts

| host | type | description |
|------|------|-------------|
| **pine** | native nixos | laptop — hyprland desktop, colemak/kmonad, steam |
| **index** | native nixos | framework ai 300 — same as pine + fingerprint reader |
| **charlie-laptop** | nixos-wsl | windows wsl — dev shell environment |
| **nico** | nixos-wsl | windows wsl — minimal shell setup |

---

## structure

```
.
├── flake.nix
├── modules/
│   ├── common/        # baseline (users, nix settings, packages, ssh)
│   ├── features/      # opt-in capabilities (steam, tailscale, fingerprint)
│   └── profiles/      # module bundles (laptop, desktop-hyprland, dev-docker, wsl)
├── hosts/             # per-machine nixos configs
└── home/
    ├── charlotte.nix  # base home-manager entry point
    ├── modules/       # per-tool home configs (shell, editor, desktop)
    ├── profiles/      # home-manager role bundles
    └── hosts/         # per-machine home overrides
```

each module handles one concern. profiles compose modules into roles. hosts stay small.

---

## desktop — pine / index

| component | choice |
|-----------|--------|
| compositor | hyprland (wayland) |
| bar | waybar |
| launcher | rofi |
| terminal | kitty — CaskaydiaCove Nerd Font, 0.8 opacity, colors from `my.theme` |
| lock / idle | hyprlock + hypridle |
| theming | [ambxst](https://github.com/Axenide/Ax-Shell) — material you wallpaper colors |
| audio | pipewire |
| screenshot | grim + slurp + swappy |

idle timeline: dim at 2.5 min → lock at 5 min → display off at 5.5 min → suspend at 30 min.

---

## desktop — apthos

gnome (wayland), autologin, driven remotely over sunshine/moonlight. riced
after OneShot's in-fiction "World Machine" OS — pure black surfaces, one
saturated purple accent (`#9664ff`), square corners, inverted selection.

| component | source |
|-----------|--------|
| cursor | `pkgs/oneshot-cursors` → `home/modules/oneshot-cursors.nix` |
| gtk2/3/4 theme | `pkgs/oneshot-gtk-theme` → `home/modules/oneshot-gtk.nix` |
| icons | `pkgs/oneshot-icons` → `home/modules/oneshot-icons.nix` |
| wallpaper | `pkgs/oneshot-wallpaper` → `home/modules/oneshot-wallpaper.nix` |
| dock | dash-to-dock, bottom panel mode (`home/profiles/desktop-gnome.nix`) |

both theme modules drive gnome through **dconf**, not home-manager's `gtk`
module: gnome-settings-daemon overrides anything written to
`gtk-3.0/settings.ini`, so settings.ini is the losing side of that race.

the gtk4 half needs a second install path on top of the theme directory —
libadwaita apps ignore `gtk-theme-name` outright, so `gtk-4.0/gtk.css` only
reaches nautilus/settings/text-editor from the *user* stylesheet at
`~/.config/gtk-4.0/`. `oneshot-gtk.nix` installs it there.

not covered: gnome shell's own chrome (top bar, overview, dash) isn't gtk
and is unaffected by any of this — it'd need a `gnome-shell.css` plus the
user themes extension.

optional: `my.oneshot-gtk.pixelFont = true;` swaps the interface font for
Terminus 10, the bitmap font the game's UI uses. off by default.

the icon theme only defines OneShot's *own* icon names (`customize`,
`jukebox`, ...), not freedesktop standard ones — guessing those would swap
icons desktop-wide. so it inherits Adwaita and mostly just makes the game's
icons available by name; it is not a wholesale icon swap.

`pkgs/oneshot-{cursors,icons,wallpaper}` are extracted game art, © Future
Cat / Komodo, marked `license = unfree` and vendored so a rebuild doesn't
need the game installed. `pkgs/oneshot-gtk-theme` is not — it's hand-written
stylesheets plus four original widget PNGs.

upstream for all four is `~/documents/code/oneshot-twm-rice`; each package's
default.nix names the `nix run .#...` command that regenerates it.

---

## color tokens

colors live in one place: `home/modules/theme/`, exposed as `my.theme`.
app modules ask for a token, not a hex value.

```
home/modules/theme/
├── default.nix     # the my.theme option tree
├── lib.nix         # role derivation + format helpers (noHash, rgbaHex, ...)
└── palettes/       # one file per palette, plain data
```

a resolved palette has two layers, and the split is the point:

| layer | contents | who reads it |
|-------|----------|--------------|
| `.palette` | the 16 ansi colors plus `bg`/`fg` | terminals, tuis, colorscheme plugins — they address colors by index or ansi name |
| `.roles` | `accent`, `border`, `selectionBg`, `muted`, ... | ui chrome — "the accent" is a job, not a hue |

roles default off the palette (`lib.nix`) and any palette can override one.
palettes also carry `.name` for apps that select a theme by string.

`my.theme.default` is the system palette, currently kanagawa, and every
app follows it: kitty, tmux, fzf, spotify-player and neovim all draw
from the same file. an app can still pin a different palette through its
own option (`my.kitty.palette`, `my.nvim.palette`).

`catppuccin-mocha` and `gruvbox-nightfox` are kept as palettes because
they are what kitty and neovim used to carry inline, and either can be
pinned back on one line.

nvf gets the theme through `extraSpecialArgs`, not `config`: it runs its
own `evalModules`, so home-manager's config is not in scope inside
`home/modules/nvf/*.nix`.

**scope.** this governs the terminal/editor/tui stack. it does *not*
govern the hyprland desktop — noctalia and ambxst derive their colors
from the wallpaper at runtime via matugen, and that is the source of
truth there. hyprland's border colors, hyprlock and the shell stay on the
runtime side deliberately. the gtk theme under `pkgs/oneshot-gtk-theme`
still carries its own literals and is not tokenized yet.

---

## shell

| tool | role |
|------|------|
| zsh | shell — completions, autosuggestions, syntax highlighting |
| oh-my-posh | prompt |
| tmux | multiplexer — colors from `my.theme`, vim pane nav, session persistence |
| atuin | shell history sync |
| zoxide + yazi | directory navigation + file manager |

---

## editor

neovim via [nvf](https://github.com/notashelf/nvf):

- lsp + format-on-save for nix, lua, python, typescript, c/c++, bash, and more
- telescope, neo-tree, treesitter, todo-comments, noice, which-key
- nightfox theme, palette from `my.theme` (`my.nvim.palette`)

---

## keyboard

colemak system-wide. on native hosts, [kmonad](https://github.com/kmonad/kmonad) adds homerow mods:

```
hold a → meta    hold s → alt    hold d → shift    hold f → ctrl
hold j → ctrl    hold k → shift  hold l → alt      hold ; → meta
```

`g`/`h` toggle a nav layer that maps `hjkl` → arrow keys.

---

## flake inputs

| input | purpose |
|-------|---------|
| nixpkgs (unstable) | package set |
| home-manager | user environment management |
| nixos-wsl | wsl integration |
| nixos-hardware | framework ai 300 hardware module |
| nvf | declarative neovim configuration |
| ambxst | desktop theming / ax-shell |
| dotfiles | bin scripts, oh-my-posh themes, yazi config |
| flake-parts | flake structure helpers |

---

## usage

```sh
# rebuild current machine
sudo nixos-rebuild switch --flake /etc/nixos#$(hostname)

# update dotfiles input
sudo nix flake lock --update-input dotfiles /etc/nixos
```
