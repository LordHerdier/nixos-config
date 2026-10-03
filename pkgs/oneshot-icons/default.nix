# pkgs/oneshot-icons/default.nix
#
# Icon theme built from OneShot's "World Machine" fake-OS desktop and
# window icons. Like pkgs/oneshot-cursors this is extracted game art
# (c) Future Cat / Komodo, vendored so a rebuild doesn't need the game
# installed. Regenerate with `nix run .#gen-icons` in
# ~/documents/code/oneshot-twm-rice and copy themes/oneshot-icons/ back
# over theme/.
#
# Scope is deliberately narrow: the theme keeps OneShot's OWN icon names
# ("customize", "jukebox", "achievements", ...) rather than guessing at
# freedesktop standard names, because a wrong semantic mapping would swap
# icons across the whole desktop. The one unambiguous exception is
# places/folder. So selecting this as the system icon theme changes very
# little on its own -- it mostly exists so our own launchers/desktop
# entries can reference the game's icons by name.
#
# index.theme inherits Adwaita (not bare hicolor): every name this theme
# does not define -- which is nearly all of them -- has to resolve through
# a complete theme, or GNOME renders missing-image glyphs everywhere.

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
