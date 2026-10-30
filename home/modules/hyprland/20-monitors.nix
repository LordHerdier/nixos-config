# home/modules/hyprland/20-monitors.nix

{ ... }:

{
  # Layout and workspace rules depend on whether the Anker hub is plugged
  # in, so they are computed in monitors.lua at config load rather than
  # declared as static attrs. See the header there.
  wayland.windowManager.hyprland.extraLuaFiles."monitors" = ./monitors.lua;
}
