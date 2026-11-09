# home/modules/hyprland/50-binds.nix

{ ... }:

{
  # Binds live in binds.lua (see its header); home-manager installs it
  # as ~/.config/hypr/binds.lua and generates the require().
  wayland.windowManager.hyprland.extraLuaFiles."binds" = ./binds.lua;
}
