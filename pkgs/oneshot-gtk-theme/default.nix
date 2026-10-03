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

{ lib, runCommandLocal }:

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
  ''
