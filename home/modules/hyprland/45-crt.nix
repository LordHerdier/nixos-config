# home/modules/hyprland/45-crt.nix

{ lib, pkgs, ... }:

let
  shaderPath = ".config/hypr/shaders/crt.frag";

  toggle = pkgs.writeShellApplication {
    name = "crt-toggle";
    runtimeInputs = [ pkgs.jq ];
    text = ''
      # Flip decoration:screen_shader between the CRT shader and nothing.
      # Hyprland applies `keyword` immediately, so there is no reload and
      # no config file to rewrite; the setting reverts on compositor
      # restart, which is the escape hatch if a shader edit goes wrong.
      shader="$HOME/${shaderPath}"

      if [ ! -r "$shader" ]; then
        echo "crt-toggle: no shader at $shader" >&2
        exit 1
      fi

      # Unset reads back as the literal "[[EMPTY]]", never as "".
      current=$(hyprctl getoption decoration:screen_shader -j | jq -r '.str')

      if [ "$current" = "$shader" ]; then
        hyprctl keyword decoration:screen_shader '[[EMPTY]]'
      else
        hyprctl keyword decoration:screen_shader "$shader"
      fi
    '';
  };
in
{
  # Software cursors are already on in 30-input.nix, which is what lets
  # the cursor get warped along with everything else. A hardware cursor
  # is composited past the shader and would float flat over the curve.
  home.file.${shaderPath}.source = ./shaders/crt.frag;

  home.packages = [ toggle ];

  # Bound to $mainMod SHIFT, G in 50-binds.nix. Deliberately off at
  # login: a shader that fails to compile leaves a black screen, and
  # recovering from that means blind-typing hyprctl. Opting in per
  # session keeps a bad shader edit from costing a login.
  wayland.windowManager.hyprland.settings."$crtToggle" = lib.getExe toggle;
}
