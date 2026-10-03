# pkgs/oneshot-gtk-theme/default.nix
#
# GTK2 + GTK3 + GTK4 theme styled after OneShot's "World Machine" fake-OS
# UI: pure black surfaces, a single saturated purple accent (#9664ff), hard
# square corners, no gradients or shadows, and an "inverted" selection
# (solid accent fill + black text) matching the game's active-tab and
# selected-icon look.
#
# Unlike pkgs/oneshot-cursors, nothing here is extracted game art. The
# stylesheets are hand-written and the four widget PNGs (diamond slider
# handle + its hover variant, checkbox tick, radio dot) are original
# drawings. Colors are plain hex values read off the game's theme data,
# which isn't a copyrightable asset. So this one is safe to keep in a
# public config repo; the extracted icon/wallpaper PNGs from the same
# project are not, and deliberately aren't vendored here.
#
# Upstream is ~/documents/code/oneshot-twm-rice (themes/oneshot/); theme/
# is a verbatim copy of its gtk-2.0, gtk-3.0 and gtk-4.0 directories, with
# gtk-4.0/assets dereferenced from a symlink into real files so the store
# path is self-contained. The XFCE half of that repo (xfwm4 pixmaps, panel
# layout) is intentionally left out -- Mutter has no pixmap decoration
# theme, and GNOME titlebars are client-side, styled by the `headerbar`
# and `windowcontrols` rules inside the GTK3/GTK4 stylesheets instead.
#
# Note the GTK4 half needs a second install step beyond this package:
# libadwaita apps ignore gtk-theme-name entirely, so gtk-4.0/gtk.css only
# reaches them from the *user* stylesheet path. See
# home/modules/oneshot-gtk.nix.
#
# COLORS ARE PARAMETERS. The six arguments below are every distinct color
# the three stylesheets use, and their defaults are the values the
# stylesheets literally contain -- so building this package with no
# arguments reproduces the game's own "Purple" theme byte for byte, and
# the stylesheets stay valid standalone CSS you can read or copy out.
# home/modules/oneshot-gtk.nix overrides them from `my.theme`.
#
# The remap works by value, not by placeholder: rather than littering
# 239 call sites with @accent@, the build rewrites each source literal
# wherever it appears. It runs in two passes through unique sentinels,
# because a target color can legitimately equal a different source color
# (swap accent and accentDim and a single pass would rewrite one into
# the other and then on again). Every source literal must still be
# present or the build fails -- that is the guard against a stylesheet
# edit silently dropping out of the remap.

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
