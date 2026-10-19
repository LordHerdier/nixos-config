# home/modules/hyprland/45-crt.nix

{ inputs, pkgs, ... }:

{
  # Software cursors are already on in 30-input.nix, which is what lets
  # the cursor get warped along with everything else. A hardware cursor
  # is composited past the shader and would float flat over the curve.
  #
  # The shader itself lives in LordHerdier/hyprCRT-shader now -- it was
  # generic enough (nothing Hyprland-session-specific beyond the
  # decoration:screen_shader contract) to be worth its own repo for
  # discoverability. This just points at the built package instead of a
  # vendored copy.
  #
  # The toggle itself is crt.lua -- see its header for why there is no
  # longer a shell script here. It is required by binds.lua rather than
  # auto-loaded, so nothing happens until the bind is pressed.
  wayland.windowManager.hyprland.extraLuaFiles."crt" = {
    content = pkgs.replaceVars ./crt.lua {
      shader = "${
        inputs.hyprCRT-shader.packages.${pkgs.stdenv.hostPlatform.system}.default
      }/share/hyprCRT/crt.frag";
    };
    autoLoad = false;
  };
}
