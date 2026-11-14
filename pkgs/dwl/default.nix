# pkgs/dwl/default.nix
#
# dwl with this repo's config.h and every patch in ./patches.
#
# PATCHES (e.g. from https://codeberg.org/dwl/dwl-patches) apply in filename
# order, so number-prefix them. They apply before ./config.h replaces
# config.h, so a patch's config.def.h hunks (binds, rules, options) have to
# be ported into ./config.h by hand.
#
# WHEN THIS BREAKS. A nixpkgs bump to a new dwl can make a patch fail to
# apply or leave ./config.h behind config.def.h. Diff against the new
# config.def.h (`nix build nixpkgs#dwl.src`) and refresh the patch.
#
# COLOURS. The parameters are only the fallback: dwl reads its real colours
# at runtime (75-theme-colours.patch) from a file modules/features/dwl
# writes. They default to the OneShot palette and reach config.h as -D flags
# rather than substituted placeholders, so config.h stays valid C for
# clangd.nix.
#
# SCREEN SHADER. `screenShader` is the fragment shader 72-screen-shader.patch
# runs over each output (Super+Shift+G), passed the same way; null keeps
# config.h's fallback. The overlay points it at ./crt.frag, hyprCRT's shader
# plus a `dwl-damage:` line giving its curve and tap reach, which lets dwl
# redraw only the pixels that can see a change; a shader without that line
# gets whole-output redraws. dwl rereads the file each time the shader is
# turned on.

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

  # drwl.h (06-bar.patch) draws the bar with fcft and DRM fourcc formats;
  # 54-bar-systray.patch talks StatusNotifierItem over libdbus;
  # 72-screen-shader.patch draws with GLES2 (libglvnd's glesv2).
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
