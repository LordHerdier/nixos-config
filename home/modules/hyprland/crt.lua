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
--
-- damage_tracking rides along with the shader, and has to. Hyprland's
-- default (2, "full") re-renders only the regions that changed, which is
-- correct for any shader that reads just the fragment it is drawing.
-- crt.frag is not that: barrel distortion warps the sample coordinate
-- away from the fragment, scatter() takes a nine-tap neighbourhood, and
-- the convergence stage offsets each channel separately. Every one of
-- those taps can land outside the damaged region, where the texture
-- still holds the previous frame -- so a partial redraw samples stale
-- pixels. It shows up as a block around the software cursor (its damage
-- rect), a colour trail behind it from the scatter and convergence taps,
-- and flickering window borders, which are thin damage regions.
--
-- 0 disables damage tracking, making the whole output valid to sample.
-- That is a full-output redraw every frame, so it is scoped to the
-- shader being on rather than set globally: off again on toggle, and
-- never paid in a session that never enables the shader.
--
-- The artifacts were always latent here and only became visible under
-- noctalia 5, which redraws its bar continuously, requests a blur region
-- through ext-background-effect-v1 (whose halo widens the damage), and
-- renders at fractional scale. That made noctalia look like the cause;
-- it is only what exposed this.
function M.toggle()
  enabled = not enabled
  hl.config({
    decoration = {
      screen_shader = enabled and shader or "",
    },
    debug = {
      damage_tracking = enabled and 0 or 2,
    },
  })
end

return M
