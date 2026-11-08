# pkgs/oneshot-icons/default.nix
#
# Icon theme from OneShot's "World Machine" desktop and window icons:
# extracted game art (c) Future Cat / Komodo, vendored like
# pkgs/oneshot-cursors. Regenerate with `nix run .#gen-icons` in
# ~/documents/code/oneshot-twm-rice and copy themes/oneshot-icons/ back over
# theme/.
#
# The theme keeps OneShot's own icon names ("customize", "jukebox", ...)
# rather than guessing freedesktop equivalents, since a wrong mapping would
# swap icons desktop-wide; places/folder is the one exception. It mostly
# exists so our own launchers can use the game's icons by name. index.theme
# inherits Adwaita, as nearly every name must resolve through a complete
# theme or GNOME shows missing-image glyphs.

{ lib, runCommandLocal }:

runCommandLocal "oneshot-icons"
  {
    meta = {
      description = "Icon theme from OneShot's World Machine desktop UI";
      # Game art, (c) Future Cat / Komodo. Fine for a personal rice, not
      # something to redistribute.
      license = lib.licenses.unfree;
      platforms = lib.platforms.all;
    };
  }
  ''
    mkdir -p "$out/share/icons"
    cp -a ${./theme} "$out/share/icons/Oneshot-Icons"
  ''
