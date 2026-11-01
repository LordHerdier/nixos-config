# pkgs/dwl/default.nix
#
# dwl with this repo's config.h and any patches dropped in ./patches.
#
# ADDING A PATCH. Put a `.patch` file in ./patches (e.g. from the dwl wiki,
# https://codeberg.org/dwl/dwl-patches) and rebuild; every file there is
# applied, in filename order, so prefix with a number if order matters.
# Patches are applied to the dwl source before ./config.h is copied over
# config.h, so a patch that changes config.def.h (new keybinds, new rules)
# does NOT reach the build by itself -- port those hunks into ./config.h too.
#
# WHEN THIS BREAKS. A nixpkgs bump to a new dwl release can make a patch fail
# to apply, or leave ./config.h behind config.def.h. Diff against the new
# config.def.h (`nix build nixpkgs#dwl.src`) and refresh the patch.
#
# COLORS ARE PARAMETERS, as #rrggbb, but only the fallback: dwl reads its
# real colours from a file at runtime (99-theme-colours.patch), which
# modules/features/dwl writes from the session user's `my.theme`. The
# defaults are the OneShot palette, which is also what config.h falls back
# to without them; they reach config.h as -D flags rather than substituted
# placeholders so config.h stays valid C for clangd.nix.
#
# SCREEN SHADER. `screenShader` is the path of the fragment shader that
# 99-screen-shader.patch runs over each output (Super+Shift+G), passed the
# same way; null leaves config.h's fallback. The overlay points it at
# hyprCRT's crt.frag. dwl reads the file each time the shader is turned on.

{
  lib,
  dwl,
  fcft,
  dbus,
  libdrm,
  libGL,
  screenShader ? null,
  bg ? "#000000",
  fg ? "#cbb8ff",
  surface ? "#000000",
  borderInactive ? "#4a3d66",
  muted ? "#4a3d66",
  accent ? "#9664ff",
  accentFg ? "#000000",
  border ? "#9664ff",
  urgent ? "#6442a5",
}:

let
  # "#rrggbb" -> -DCOL_X=0xrrggbbff, the RGBA int config.h's COLOR() wants.
  define = name: hex: "-DCOL_${name}=0x${lib.toLower (lib.removePrefix "#" hex)}ff";
in
(dwl.override { configH = ./config.h; }).overrideAttrs (old: {
  env = (old.env or { }) // {
    NIX_CFLAGS_COMPILE =
      toString [
        (old.env.NIX_CFLAGS_COMPILE or "")
        (define "BG" bg)
        (define "FG" fg)
        (define "SURFACE" surface)
        (define "BORDER_INACTIVE" borderInactive)
        (define "MUTED" muted)
        (define "ACCENT" accent)
        (define "ACCENT_FG" accentFg)
        (define "BORDER" border)
        (define "URGENT" urgent)
      ]
      # The quotes reach the compiler as-is (NIX_CFLAGS_COMPILE is split on
      # whitespace, not shell-parsed), making the macro a string literal.
      + lib.optionalString (screenShader != null) " -DSCREEN_SHADER=\"${screenShader}\"";
  };

  # drwl.h (05-bar.patch) draws the bar with fcft and DRM fourcc formats;
  # 90-bar-systray.patch talks StatusNotifierItem over libdbus;
  # 99-screen-shader.patch draws with GLES2 (libglvnd's glesv2).
  buildInputs = (old.buildInputs or [ ]) ++ [
    dbus
    fcft
    libdrm
    libGL
  ];

  patches =
    (old.patches or [ ])
    ++ (
      let
        dir = ./patches;
      in
      map (name: dir + "/${name}") (
        builtins.filter (name: builtins.match ".*\\.patch" name != null) (
          builtins.attrNames (builtins.readDir dir)
        )
      )
    );
})
