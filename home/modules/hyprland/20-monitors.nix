# home/modules/hyprland/20-monitors.nix

{ ... }:

{
  # Layout and workspace rules depend on whether the Anker hub is plugged
  # in, so monitors.lua computes them at config load.
  wayland.windowManager.hyprland.extraLuaFiles."monitors" = ./monitors.lua;
}
