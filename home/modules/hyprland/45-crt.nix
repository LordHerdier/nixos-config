# home/modules/hyprland/45-crt.nix

{ inputs, pkgs, ... }:

{
  # Software cursors are already on in 30-input.nix, which is what lets
  # the cursor get warped along with everything else. A hardware cursor
  # is composited past the shader and would float flat over the curve.
  #
  # The shader and its toggle both live in LordHerdier/hyprCRT-shader
  # now -- it was generic enough (nothing Hyprland-session-specific
  # beyond the decoration:screen_shader contract) to be worth its own
  # repo for discoverability. This used to reimplement the toggle as a
  # bound Lua function (crt.lua, M.toggle()) calling hl.config directly,
  # but that reimplementation couldn't pick up the upstream fix for
  # artifacting on disable: hyprctl reload has to run from a *separate*
  # process after the config write, not from inside the compositor's own
  # Lua runtime handling the keypress -- calling os.execute("hyprctl
  # reload") from there deadlocks the IPC (confirmed by hand: the eval
  # call hangs until it times out). toggle.sh gets that right because
  # it's always a separate process. So instead of keeping a parallel,
  # increasingly-stale copy of that logic here, the package's
  # bin/hyprcrt-toggle just goes on PATH and binds.lua execs it like any
  # other external command -- see its "Everything here is resolved from
  # PATH" note.
  home.packages = [
    inputs.hyprCRT-shader.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
