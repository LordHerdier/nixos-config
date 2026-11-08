# home/modules/hyprland/45-crt.nix

{ inputs, pkgs, ... }:

{
  # CRT shader + toggle from LordHerdier/hyprCRT-shader; binds.lua execs
  # its hyprcrt-toggle (Super+Shift+G). Software cursors (30-input.nix)
  # are required: a hardware cursor bypasses the shader and floats flat
  # over the curve.
  #
  # Don't reimplement the toggle as a bound Lua function: it has to run
  # `hyprctl reload` after the config write, and doing that from inside
  # the compositor's Lua runtime (os.execute) deadlocks the IPC. A
  # separate process avoids it.
  home.packages = [
    inputs.hyprCRT-shader.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
