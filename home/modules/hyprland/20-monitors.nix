# home/modules/hyprland/20-monitors.nix
#
# Monitor layout is per device, so it lives in its own Lua file chosen per
# host instead of one file that assumes Index's outputs.
#
# Override spot, in order of precedence:
#   1. my.hyprland.monitorsFile set in the host's home/hosts/<host>.nix
#   2. monitors/<hostName>.lua, picked up automatically
#   3. monitors/default.lua (no rules; Hyprland autodetects)
#
# Real Lua rather than Nix attrs: Index's layout is computed at config
# load (dock detection), see monitors/Index.lua.

{
  hostName,
  lib,
  config,
  ...
}:

let
  perHost = ./monitors + "/${hostName}.lua";
in
{
  options.my.hyprland.monitorsFile = lib.mkOption {
    type = lib.types.path;
    default = if builtins.pathExists perHost then perHost else ./monitors/default.lua;
    defaultText = lib.literalExpression "./monitors/<hostName>.lua if it exists, else ./monitors/default.lua";
    description = ''
      Lua file installed as Hyprland's `monitors` module. It runs on every
      config reload and declares this device's hl.monitor() and
      hl.workspace_rule() entries.
    '';
  };

  config.wayland.windowManager.hyprland.extraLuaFiles."monitors" = config.my.hyprland.monitorsFile;
}
