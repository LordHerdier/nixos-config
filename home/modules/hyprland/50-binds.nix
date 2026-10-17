# home/modules/hyprland/50-binds.nix

{ ... }:

{
  # The binds themselves live in binds.lua -- see the header there for
  # why they are not Nix attrs. home-manager writes it to
  # ~/.config/hypr/binds.lua and generates the require() for it.
  wayland.windowManager.hyprland.extraLuaFiles."binds" = ./binds.lua;
}
