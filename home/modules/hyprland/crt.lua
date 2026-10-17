-- home/modules/hyprland/crt.lua
--
-- CRT screen shader, toggled in-process. The hyprlang version of this
-- had to be a shell script (hyprctl getoption | jq, then hyprctl
-- keyword) because the config language could not read or write its own
-- options. Lua can: hl.bind takes a function, and
-- decoration.screen_shader is a live config key, so the whole script,
-- its jq dependency and the [[EMPTY]] sentinel are gone.
--
-- @shader@ is the shader's store path, substituted by 45-crt.nix.
-- Editing crt.frag still means a rebuild, exactly as it did when the
-- copy under ~/.config/hypr/shaders was a read-only store symlink.
--
-- Deliberately off at login, and off again after any compositor
-- restart: a shader that fails to compile leaves a black screen, and
-- recovering from that means blind-typing hyprctl. Opting in per session
-- keeps a bad shader edit from costing a login.
--
-- Not auto-loaded; binds.lua requires it and binds M.toggle.

local M = {}

local shader = "@shader@"
local enabled = false

-- "" is the off value: hyprctl accepts it for screen_shader and reads it
-- back as an empty string. Unset-at-startup reads back as "[[EMPTY]]",
-- but that is a hyprlang parser sentinel and is not what to write here.
function M.toggle()
  enabled = not enabled
  hl.config({
    decoration = {
      screen_shader = enabled and shader or "",
    },
  })
end

return M
