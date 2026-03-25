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
| terminal | kitty — CaskaydiaCove Nerd Font, 0.4 opacity |
| lock / idle | hyprlock + hypridle |
| theming | [ambxst](https://github.com/Axenide/Ax-Shell) — material you wallpaper colors |
| audio | pipewire |
| screenshot | grim + slurp + swappy |

idle timeline: dim at 2.5 min → lock at 5 min → display off at 5.5 min → suspend at 30 min.

---

## shell

| tool | role |
|------|------|
| zsh | shell — completions, autosuggestions, syntax highlighting |
| oh-my-posh | prompt |
| tmux | multiplexer — kanagawa theme, vim pane nav, session persistence |
| atuin | shell history sync |
| zoxide + yazi | directory navigation + file manager |

---

## editor

neovim via [nvf](https://github.com/notashelf/nvf):

- lsp + format-on-save for nix, lua, python, typescript, c/c++, bash, and more
- telescope, neo-tree, treesitter, todo-comments, noice, which-key
- nightfox theme with a custom gruvbox-inspired palette

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
