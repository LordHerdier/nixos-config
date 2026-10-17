# Migrating `home/modules/hyprland` from hyprlang to Lua

Status: landed on Index on 2026-10-17 and verified there. **Pine imports
the same profile and has not been restarted yet** -- see the warning in
section 7 about what a reload does. Delete this file once Pine is done.

Written against the two authoritative references for the target syntax:

- the home-manager renderer, `modules/services/window-managers/hyprland/{default,lib}.nix`
  in the pinned `home-manager` input
- Hyprland 0.56.2's own `$out/share/hypr/hyprland.lua` (the shipped
  example config) and `$out/share/hypr/stubs/hl.meta.lua` (generated
  type stubs for the whole `hl` API)

Both are in the store; `nix eval --raw --impure --expr
'(builtins.getFlake "/etc/nixos").inputs.nixpkgs.legacyPackages.x86_64-linux.hyprland.outPath'`
finds the latter.

## 1. Current state and scope

`default.nix` pins `configType = "hyprlang"`. That option's default flips
to `"lua"` at `home.stateVersion = "26.05"`; charlotte is on `25.05`, so
nothing changes under us. This migration is voluntary, and the pin is the
one line that flips it.

Only `wayland.windowManager.hyprland.settings` is affected. Out of scope,
because they are separate programs with their own hyprlang parsers:

- `hyprlock.nix`, `hyprlock-colors.nix` -- hyprlock has no Lua config; it
  keeps sourcing `noctalia-colors.conf`
- `hypridle.nix` -- `services.hypridle.settings` is its own generator
- `shaders/crt.frag`, eww, noctalia IPC, hyprshot/hyprpicker -- unaffected

Both `home/hosts/Index.nix` and `home/hosts/Pine.nix` import
`home/profiles/desktop-hyprland.nix`, so the switch lands on both hosts.

## 2. The renderer contract

In Lua mode home-manager writes `~/.config/hypr/hyprland.lua`, mapping
each `settings.<name>` to an `hl.<name>(...)` call. A list value emits one
call per element. Three escape hatches:

| Nix | Lua |
|---|---|
| `foo = { a = 1; }` | `hl.foo({ a = 1 })` |
| `foo = { _args = [ x y ]; }` | `hl.foo(x, y)` |
| `foo = { _var = "SUPER"; }` | `local foo = "SUPER"` |
| `lib.generators.mkLuaInline "hl.dsp.window.close()"` | raw Lua, unquoted |

Plus `extraLuaFiles."name" = <path or lines>` writes
`~/.config/hypr/name.lua` and generates a `require("name")` for it.

Output order in the generated file: locals, then names matching
`importantPrefixes` (default `[ "$" "bezier" "curve" "name" "output" ]`),
then alphabetical. `curve` matches, so curves land before `animation`,
which is what we want. If ordering ever matters elsewhere, add a prefix
to `importantPrefixes`.

Free bonus: Lua mode also generates `~/.config/hypr/.luarc.json` pointing
`lua_ls` at the stubs, so nvf gets completion and type checking on any
Lua we write by hand.

## 3. Target file layout

The numbered-module structure survives intact. `settings.config` is an
attrset, so all the modules that touch it merge into a single
`hl.config({ ... })` call.

```
20-monitors.nix   -> settings.monitor, settings.workspace_rule
30-input.nix      -> settings.config.{input,cursor}
40-design.nix     -> settings.config.{general,decoration,misc,dwindle,master}
                     settings.env, settings.curve, settings.animation
45-crt.nix        -> see section 5
50-binds.nix      -> extraLuaFiles."binds" = pkgs.replaceVars ./binds.lua {...}
                     + binds.lua (new)
default.nix       -> settings.on (startup hook), configType = "lua"
```

## 4. File-by-file mapping

### 20-monitors.nix

The CSV string positions become named fields, and `workspace` becomes
`workspace_rule`:

```nix
monitor = [
  { output = "eDP-1"; mode = "2880x1920@120"; position = "0x0";     scale = 1.33; }
  { output = "DP-2";  mode = "2560x1440@165"; position = "0x-1440"; scale = 1; }
];

workspace_rule = [
  { workspace = "1"; monitor = "eDP-1"; }
  { workspace = "2"; monitor = "DP-2"; }
  # ... 3-11 unchanged in meaning
];
```

The commented-out alternates translate the same way: `disabled = true`,
`mirror = "eDP-1"`. Worth keeping them as comments.

### 30-input.nix

Nest the whole thing under `config`; otherwise identical.
`cursor.no_hardware_cursors = true` stays valid -- the stub types it
`integer|boolean`.

### 40-design.nix

Three real changes: `env` takes two positional args, `bezier` becomes
`curve` with structured control points, and `animation` strings become
named fields.

```nix
env = [
  { _args = [ "XCURSOR_SIZE" (toString cursorSize) ]; }
  { _args = [ "XCURSOR_THEME" "phinger-cursors-light" ]; }
  # HYPRCURSOR_SIZE / HYPRCURSOR_THEME the same
];

# "myBezier, 0, 1, 0.18, 1.0" -> name + two control points
curve = [
  { _args = [ "myBezier" { type = "bezier"; points = [ [ 0 1 ] [ 0.18 1.0 ] ]; } ]; }
];

# hyprlang order was NAME, ONOFF, SPEED, CURVE[, STYLE]
animation = [
  { leaf = "windows";     enabled = true; speed = 1.5; bezier = "myBezier"; }
  { leaf = "windowsOut";  enabled = true; speed = 2;   bezier = "myBezier"; style = "popin 95%"; }
  { leaf = "border";      enabled = true; speed = 12;  bezier = "myBezier"; }
  { leaf = "borderangle"; enabled = true; speed = 5;   bezier = "default"; }
  { leaf = "fade";        enabled = true; speed = 6;   bezier = "default"; }
  { leaf = "workspaces";  enabled = true; speed = 6;   bezier = "default"; }
];

config = {
  animations.enabled = true;

  general = {
    gaps_in = 5;
    gaps_out = 10;
    border_size = 4;

    # the quoted dotted keys go away entirely
    col = {
      active_border = {
        colors = [ "rgba(113,255,255,0.33)" "rgba(82,113,163,0.3)" ];
        angle = 120;
      };
      inactive_border = "rgba(89,70,196,0.3)";
    };

    resize_on_border = true;
    layout = "dwindle";
    allow_tearing = false;
  };

  # decoration / misc / dwindle / master: same keys, now under `config`.
  # decoration.shadow and decoration.blur were already nested and stay so.
};
```

Gradients are the structural win here: `"a b 120deg"` becomes
`{ colors = [ ... ]; angle = 120; }`, which is what makes the border
colors tokenizable from `my.theme` later. The README calls that out as the
one place the Hyprland side is still hardcoded literals.

### 50-binds.nix

The bulk of the work. Encoding ~90 binds as
`{ _args = [ ... (mkLuaInline "...") ]; }` would be unreadable, so write
real Lua and let Nix substitute only the store paths -- same reasoning as
keeping `crt.frag` in its own file.

```nix
# 50-binds.nix
wayland.windowManager.hyprland.extraLuaFiles."binds" =
  pkgs.replaceVars ./binds.lua {
    shader = ./shaders/crt.frag;   # see section 5
  };
```

```lua
-- binds.lua
local mainMod  = "SUPER"
local ipc      = "noctalia-shell ipc call "
local terminal = "kitty"

hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("qylock-lock"))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exit())   -- was `hyprctl dispatch exit`
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(ipc .. "launcher toggle"))
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))

-- Colemak focus keys and the arrow keys, one loop instead of eight lines
for _, d in ipairs({ { "n", "left" }, { "i", "right" }, { "u", "up" }, { "e", "down" } }) do
  hl.bind(mainMod .. " + " .. d[1], hl.dsp.focus({ direction = d[2] }))
  hl.bind(mainMod .. " + " .. d[2], hl.dsp.focus({ direction = d[2] }))
end

for i = 1, 10 do
  local key = i % 10   -- 10 maps to key 0
  hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(ipc .. "volume increase"),
        { locked = true, repeating = true })
```

Dispatcher mapping for everything currently bound:

| hyprlang | Lua |
|---|---|
| `killactive` | `hl.dsp.window.close()` |
| `fullscreen` / `pseudo` / `pin` | `hl.dsp.window.fullscreen()` / `.pseudo()` / `.pin()` |
| `togglefloating` | `hl.dsp.window.float({ action = "toggle" })` |
| `movefocus, l` | `hl.dsp.focus({ direction = "left" })` |
| `workspace, 3` | `hl.dsp.focus({ workspace = 3 })` |
| `movetoworkspace, 3` | `hl.dsp.window.move({ workspace = 3 })` |
| `exec, cmd` | `hl.dsp.exec_cmd("cmd")` |
| `exit` | `hl.dsp.exit()` |
| `bindm ... movewindow` | `hl.bind(..., hl.dsp.window.drag(), { mouse = true })` |
| `bindm ... resizewindow` | `hl.bind(..., hl.dsp.window.resize(), { mouse = true })` |

The `$var` indirection at the top of the module becomes Lua locals. Two
things become expressible that were not before:

- `{ description = "..." }` per bind -- real bind descriptions, which is
  presumably what `~/bin/binds-menu` wanted to scrape. Note that neither
  `~/bin/binds-menu` nor `~/bin/wall_video` exists on this machine and
  neither is in the repo or the dotfiles input, so verify those three
  binds (`$bindsMenu`, and `$wallScript next`/`prev`) are not already
  dead before carrying them over.
- `{ locked = true }` on the hardware keys, so volume and brightness work
  while hyprlock is up.

`exec, [float] kitty` needs checking: `hl.exec_cmd` takes an optional
rules table (`hl.exec_cmd(cmd, { float = true })` per the stub), but
`hl.dsp.exec_cmd` is typed `fun(...)`, so confirm the dispatcher form
accepts the second argument. If it does not, a `hl.window_rule` matching
on class is the fallback.

### default.nix

`exec-once` becomes a startup hook:

```nix
settings.on = [{
  _args = [
    "hyprland.start"
    (lib.generators.mkLuaInline ''
      function()
        hl.exec_cmd("noctalia-shell")
        hl.exec_cmd("hyprpolkitagent")
        hl.timer(function() hl.exec_cmd("kitty zsh -i -c t") end,
                 { timeout = 2000, type = "oneshot" })
      end'')
  ];
}];
```

That retires both the `sleep 2 &&` shell and the hardcoded
`/etc/profiles/per-user/charlotte/bin/kitty` path. home-manager emits its
own `hl.on("hyprland.start", ...)` for the systemd activation; multiple
subscriptions to one event are fine. `settings.on` must be a list for
that reason -- an attrset would only allow one hook.

Keep the existing comment about gnome-keyring being started by PAM.

## 5. The one real design decision: 45-crt.nix

The shell script exists because hyprlang had no way to flip
`screen_shader` from inside the config. Lua does: `hl.bind` accepts a
function, and `decoration.screen_shader` is a live config key (it is in
`HL.ConfigKey` in the stubs). The `writeShellApplication` + `jq` +
`hyprctl getoption`/`keyword` + `[[EMPTY]]` sentinel dance collapses to:

```lua
local crt_on, shader = false, "@shader@"   -- store path, substituted by Nix
hl.bind(mainMod .. " + SHIFT + G", function()
  crt_on = not crt_on
  hl.config({ decoration = { screen_shader = crt_on and shader or "" } })
end, { description = "Toggle CRT shader" })
```

This also drops the `home.file.".config/hypr/shaders/crt.frag"` copy and
the `$HOME` indirection -- the shader is referenced straight from the
store. The module's comments about *why the shader is off at login* and
*why software cursors are required* still apply verbatim and must be
carried over to wherever the bind ends up.

There is no fallback. `hyprctl keyword` is in 0.56.2's help text but is
rejected at runtime once the config is Lua:

    $ hyprctl keyword decoration:screen_shader ""
    keyword can't work with non-legacy parsers. Use eval.

So the script could not have kept working whatever we did. `hyprctl eval
<lua>` is its replacement and is worth knowing about: it executes Lua in
the running compositor, which is the only way to poke at config state by
hand now (`hyprctl eval 'hl.config({ ... })'`).

## 6. Verification results

All resolved on Index. What was checked, and how:

1. **`hl.config()` applies `screen_shader` at runtime** -- yes, in both
   directions, and it merges rather than replacing the section (rounding,
   blur and shadow all survive a toggle). Proved before switching by
   arming `hl.timer(crt.toggle, ...)` in a nested instance and watching
   `hyprctl getoption`.
2. **`{ mouse = true }` is not honoured** -- the three drag binds register
   with `mouse: False` in `hyprctl binds`. `{ drag = true }` and
   `{ click = true }` do not change that either. It does not matter: the
   drag behaviour comes from the `hl.dsp.window.drag()` / `.resize()`
   dispatchers, and move/resize-by-drag works. The flag is left in place
   because Hyprland's own example config passes it.
3. **`misc.force_default_wallpaper = 0`** -- accepted, reads back as 0.
4. **Colemak keys** -- `resolve_binds_by_sym` is `false` (default), same
   as before the migration, and the binds register on `n`/`i`/`u`/`e`.
5. **Startup hook** -- fires correctly; noctalia and the kitty autostart
   both come up.
6. **`hl.dsp.exec_cmd(cmd, { float = true })`** -- works; `SUPER + T`
   still floats.

Bind count is the cheap regression check: 52 static calls + 8 from the
focus loop + 20 from the workspace loop = 80, and `hyprctl binds`
reports 80.

Known cosmetic artefact: swapping `screen_shader` flickers while the
renderer re-initialises. Not specific to the shader -- any `hl.config()`
change does it, including a plain `rounding` change -- so there is
nothing to fix here.

## 7. Staging and rollback

A malformed Lua file is a worse failure than a malformed hyprlang one: a
syntax error means the compositor comes up with no config at all. That is
the same hazard `45-crt.nix` already documents for a bad shader, so treat
it the same way.

- **A reload is not enough: Hyprland must be restarted.** It chooses
  `hyprland.lua` vs `hyprland.conf` once at startup and never
  re-evaluates, so a session started before the switch stays in hyprlang
  mode. home-manager's `onChange` then runs `hyprctl reload config-only`,
  Hyprland re-reads its remembered `hyprland.conf` path, finds the file
  gone, and **auto-generates a stub** there ("This config is a STUB!")
  and loads that. Every option reads `set: false` and it looks exactly
  like the switch silently failed. The running compositor also rewrites
  that stub seconds after it is deleted, so clean it up only after
  logging back in. Check which format a session is using with:
  `grep '\[cfg\]' $XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/hyprland.log`
- To validate a Lua config *without* logging out, run a nested Hyprland
  against a copy of the generated config with the
  `hl.on("hyprland.start"/"hyprland.shutdown")` hooks stripped (otherwise
  it stops the outer session's `hyprland-session.target`):
  `XDG_CONFIG_HOME=<copy> Hyprland`, then check
  `hyprctl -i <sig> configerrors` and `hyprctl -i <sig> binds`. This is
  what caught the `mouse = true` issue before the switch.
- Work on a branch. `nixos-rebuild build` first and read the generated
  `~/.config/hypr/hyprland.lua` out of `result/` before switching.
- Switch **Index** first (laptop, physically present), with a TTY
  available. Pine after.
- Rollback is a previous generation, not a file edit: after the switch,
  `hyprland.conf` is gone from `~/.config/hypr` and only `hyprland.lua`
  is there. For a bail-out that needs no rebuild, copy the current
  generated `hyprland.conf` out of the store to `~/hyprland.conf.bak`
  beforehand.
- `onChange` runs `hyprctl reload config-only` identically in both modes,
  so a live session picks up changes the same way.

## 8. Commit sequence

1. `migrate hyprland monitors and input to the lua config` -- flip
   `configType = "lua"`, convert 20 and 30 only. Binds being absent for
   one build is survivable, but **do not switch** here; `nix build` only.
2. `convert hyprland design settings to hl.config/hl.curve/hl.animation`
   -- 40-design.
3. `move hyprland binds into a real lua file` -- 50-binds + `binds.lua`.
4. `drive the crt shader from lua instead of hyprctl` -- 45-crt, dropping
   the script.
5. `convert exec-once into a hyprland.start hook` -- default.nix.

Steps 1 to 3 are mechanical. Step 4 is the only one that changes
behaviour, so it lands last and a revert is a single commit.

As committed, step 5 was folded into step 1: `hl.exec-once` is not a
valid Lua identifier, so the generated file does not parse until the
startup hook moves, which makes splitting it out pointless.

Finally, update the README's hypr section: the paragraph about noctalia's
template wanting to edit `~/.config/hypr/hyprland.conf` needs rewording,
and the "border colours are still literals" gap gets easier to close once
gradients are structured attrsets.
