-- home/modules/hyprland/binds.lua
--
-- Keybinds, ported from the hyprlang `bind`/`bindm` lists. Written as
-- real Lua rather than Nix attrs because the `_args` + mkLuaInline
-- encoding home-manager needs for hl.bind() is unreadable at ~90 binds,
-- and because loops collapse the workspace and focus blocks. The
-- generated hypr/.luarc.json points lua_ls at Hyprland's own stubs, so
-- this file gets completion and type checking in nvim.
--
-- Everything here is resolved from PATH, exactly as the hyprlang version
-- was; nothing needs substituting from Nix.

local mainMod = "SUPER"

-- Noctalia shell IPC (routed through the shell for OSD feedback)
local ipc = "noctalia-shell ipc call "

-- Apps. browser, calculator, fileManager and mailApp were declared as
-- hyprlang variables but never actually bound, and music/fileManager
-- disagreed with the literals the binds used (spotify vs
-- spotify-launcher, nautilus vs thunar). Carried over verbatim so the
-- discrepancy stays visible rather than being silently resolved.
local browser = "zen"
local calculator = "qalculate-gtk"
local fileManager = "thunar"
local ide = "code"
local mailApp = "thunderbird"
local music = "spotify-launcher"
local terminal = "kitty"
local menu = ipc .. "launcher toggle"

-- Commands
local colorpicker = "hyprpicker -qaf rgb"
local lock = "qylock-lock"
local screenshot = "hyprshot --mode region --output-folder ~/Pictures/Screenshots"
local wallScript = "~/bin/wall_video"
local bindsMenu = "~/bin/binds-menu"

-- Essentials
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd(lock))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exit())

-- Wallpapers
hl.bind(mainMod .. " + ALT + 1", hl.dsp.exec_cmd(wallScript .. " next"))
hl.bind(mainMod .. " + ALT + 2", hl.dsp.exec_cmd(wallScript .. " prev"))
hl.bind(mainMod .. " + ALT + 3", hl.dsp.exec_cmd(ipc .. "wallpaper random"))

-- Launchers
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + H", hl.dsp.exec_cmd(bindsMenu))
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal, { float = true }))
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd("hacky-tts-toggle"))
hl.bind(mainMod .. " + grave", hl.dsp.exec_cmd("hacky-launcher-toggle"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(screenshot))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd(colorpicker))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("moonlight stream 'nico' 'desktop'"))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("nautilus"))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(ide))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("zen-beta"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("spotify"))

-- Noctalia launchers
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd(ipc .. "launcher clipboard"))
hl.bind(mainMod .. " + period", hl.dsp.exec_cmd(ipc .. "launcher emoji"))
hl.bind(mainMod .. " + Tab", hl.dsp.exec_cmd(ipc .. "launcher windows"))
hl.bind(mainMod .. " + SHIFT + SPACE", hl.dsp.exec_cmd(ipc .. "launcher command"))

-- Noctalia panels & menus
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(ipc .. "controlCenter toggle"))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd(ipc .. "sessionMenu toggle"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(ipc .. "notifications toggleHistory"))
hl.bind(mainMod .. " + ALT + W", hl.dsp.exec_cmd(ipc .. "notifications toggleDND"))
hl.bind(mainMod .. " + comma", hl.dsp.exec_cmd(ipc .. "settings toggle"))
hl.bind(mainMod .. " + K", hl.dsp.exec_cmd(ipc .. "calendar toggle"))

-- Noctalia toggles
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd(ipc .. "bar toggle"))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd(ipc .. "darkMode toggle"))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd(ipc .. "nightLight toggle"))
hl.bind(mainMod .. " + SHIFT + I", hl.dsp.exec_cmd(ipc .. "idleInhibitor toggle"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd(ipc .. "plugin:screen-recorder toggle"))

-- Display filters. Still the crt-toggle script off PATH (home.packages in
-- 45-crt.nix); it becomes a Lua closure in the next commit.
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.exec_cmd("crt-toggle"))

-- Window management
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.window.pin())

-- Focus. Colemak home row (n/i/u/e) and the arrow keys, same directions.
for _, d in ipairs({
  { "n", "left" },
  { "i", "right" },
  { "u", "up" },
  { "e", "down" },
}) do
  hl.bind(mainMod .. " + " .. d[1], hl.dsp.focus({ direction = d[2] }))
  hl.bind(mainMod .. " + " .. d[2], hl.dsp.focus({ direction = d[2] }))
end

-- Workspaces. Keys 1-9 map to 1-9, key 0 to workspace 10; workspace 11
-- has a monitor rule in 20-monitors.nix but no bind, as before.
for i = 1, 10 do
  local key = i % 10
  hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Mouse binds, was `bindm`
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind(mainMod .. " + SHIFT + mouse:272", hl.dsp.window.resize(), { mouse = true })

-- Hardware keys. `locked = true` is new: it lets volume and brightness
-- work while hyprlock is up, which the hyprlang binds could not express
-- and which matches Hyprland's own example config.
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(ipc .. "volume increase"),
  { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(ipc .. "volume decrease"),
  { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(ipc .. "volume muteOutput"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd(ipc .. "volume muteInput"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd(ipc .. "media playPause"), { locked = true })
hl.bind("XF86AudioStop", hl.dsp.exec_cmd(ipc .. "media stop"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd(ipc .. "media previous"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd(ipc .. "media next"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(ipc .. "brightness increase"),
  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(ipc .. "brightness decrease"),
  { locked = true, repeating = true })
