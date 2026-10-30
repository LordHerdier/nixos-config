-- home/modules/hyprland/monitors.lua
--
-- Monitor layout and workspace rules, switched on whether the Anker USB-C
-- hub is plugged in. Real Lua rather than Nix attrs because the layout is
-- computed at config load; evaluated on every reload, so docking later
-- needs a `hyprctl reload` to take effect.

-- Anker USB C Hub HN. Matched on vendor:product via sysfs instead of
-- parsing `lsusb`: the bus/device numbers change on every replug, and this
-- doesn't need usbutils on Hyprland's PATH. Lua has no directory listing,
-- so the only subprocess is a coreutils `ls` for the glob.
local DOCK_ID = { vendor = "291a", product = "8385" }

local function readfile(path)
  local f = io.open(path, "r")
  if not f then
    return nil
  end
  local s = f:read("*l")
  f:close()
  return s
end

local function docked()
  local p = io.popen("ls -d /sys/bus/usb/devices/*/idVendor 2>/dev/null")
  if not p then
    return false
  end
  for vendor_path in p:lines() do
    local dir = vendor_path:gsub("/idVendor$", "")
    if readfile(vendor_path) == DOCK_ID.vendor and readfile(dir .. "/idProduct") == DOCK_ID.product then
      p:close()
      return true
    end
  end
  p:close()
  return false
end

local is_docked = docked()

local internal = {
  output = "eDP-1",
  mode = "2880x1920@120",
  scale = 1.33,
}

local external = {
  output = "DP-4",
  mode = "2560x1440@165",
  scale = 1,
}

if is_docked then
  -- External at the origin, laptop panel to its right (2560 = DP-4 width),
  -- top edges aligned.
  external.position = "0x0"
  internal.position = "2560x0"
else
  internal.position = "0x0"
  external.position = "0x-1440"
end

hl.monitor(internal)
hl.monitor(external)

-- Docked: DP-4 takes the odd workspaces, eDP-1 the even ones. Undocked
-- there is only one screen, so no rules are needed and everything lands
-- on eDP-1.
if is_docked then
  for ws = 1, 10 do
    hl.workspace_rule({
      workspace = tostring(ws),
      monitor = (ws % 2 == 1) and external.output or internal.output,
    })
  end
end
