# pkgs/oneshot-gtk-theme/default.nix
#
# GTK2/3/4 + GNOME Shell theme styled after OneShot's "World Machine" UI:
# black surfaces, one purple accent (#9664ff), square corners, no gradients
# or shadows, and an inverted selection (accent fill, black text).
#
# Unlike pkgs/oneshot-cursors, nothing here is extracted game art: the
# stylesheets are hand-written, the widget PNGs (slider diamond + hover,
# check, radio dot) are original drawings, and the colours are just hex
# values.
#
# theme/gtk-{2,3,4}.0 are a verbatim copy of themes/oneshot/ in
# ~/documents/code/oneshot-twm-rice, with gtk-4.0/assets dereferenced from a
# symlink. Its XFCE half (xfwm4 pixmaps, panel) is left out: GNOME titlebars
# are client-side, styled by the GTK3/4 `headerbar` rules instead.
# theme/gnome-shell and theme/gtk-4.0/app-overrides.css are ours (the rice
# targets XFCE and has no libadwaita apps); keeping the overrides beside
# gtk.css lets gtk.css stay a plain copy.
#
# GTK4 and the Shell each need a second install step (libadwaita ignores
# gtk-theme-name; the Shell needs the User Themes extension): see
# home/modules/oneshot-gtk.nix, which also sets the colours from `my.theme`.
#
# COLOURS ARE PARAMETERS. The six arguments are every palette colour the
# stylesheets use, defaulting to the literal values in them, so a plain
# build is the game's "Purple" theme and the CSS stays valid standalone.
# The build rewrites each literal by value rather than via placeholders, in
# two passes through unique sentinels, since a target can equal another
# source colour (swapping accent and accentDim would otherwise chain). A
# source literal that has gone missing fails the build, so a stylesheet
# edit can't silently drop out of the remap.

{
  lib,
  runCommandLocal,

  # Surfaces.
  background ? "#000000",
  # The one non-black surface in the theme: GTK2's bg[PRELIGHT] hover.
  backgroundHover ? "#1a1a1a",

  # The single saturated accent, and its three derived shades.
  accent ? "#9664ff",
  # Pressed/checked fills and destructive actions.
  accentDim ? "#6442a5",
  # Disabled text, separators, insensitive borders.
  accentMuted ? "#4a3d66",
  # The accent lightened for standalone text and icons, and the theme's
  # general foreground.
  accentStandalone ? "#cbb8ff",
}:

let
  # Order is irrelevant (the sentinel pass makes the remap atomic), but
  # keeping it stable keeps the build log readable.
  remap = [
    {
      name = "background";
      from = "#000000";
      to = background;
    }
    {
      name = "backgroundHover";
      from = "#1a1a1a";
      to = backgroundHover;
    }
    {
      name = "accent";
      from = "#9664ff";
      to = accent;
    }
    {
      name = "accentDim";
      from = "#6442a5";
      to = accentDim;
    }
    {
      name = "accentMuted";
      from = "#4a3d66";
      to = accentMuted;
    }
    {
      name = "accentStandalone";
      from = "#cbb8ff";
      to = accentStandalone;
    }
  ];

  # sed -i with /I: the GTK2 gtkrc spells the accent "#9664FF".
  pass1 = lib.concatMapStrings (
    i:
    let
      e = builtins.elemAt remap i;
    in
    ''
      if ! grep -qiE -- '${e.from}' $files; then
        echo "oneshot-gtk-theme: ${e.from} (${e.name}) no longer appears in the" \
             "stylesheets -- the remap is stale, fix the color list in default.nix" >&2
        exit 1
      fi
      sed -i "s/${e.from}/@@OSC${toString i}@@/Ig" $files
    ''
  ) (lib.genList lib.id (builtins.length remap));

  pass2 = lib.concatMapStrings (
    i:
    let
      e = builtins.elemAt remap i;
    in
    ''
      sed -i "s/@@OSC${toString i}@@/${e.to}/g" $files
    ''
  ) (lib.genList lib.id (builtins.length remap));
in
runCommandLocal "oneshot-gtk-theme"
  {
    meta = {
      description = "GTK2/3/4 theme styled after OneShot's World Machine desktop UI";
      license = lib.licenses.mit;
      platforms = lib.platforms.all;
    };
  }
  ''
    mkdir -p "$out/share/themes"
    cp -a ${./theme} "$out/share/themes/Oneshot"
    chmod -R u+w "$out/share/themes/Oneshot"

    files=$(find "$out/share/themes/Oneshot" -type f \( -name '*.css' -o -name gtkrc \))

    ${pass1}
    ${pass2}

    if grep -qE -- '@@OSC[0-9]+@@' $files; then
      echo "oneshot-gtk-theme: unsubstituted sentinel left in the stylesheets" >&2
      grep -nE -- '@@OSC[0-9]+@@' $files >&2
      exit 1
    fi
  ''
