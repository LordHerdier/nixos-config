# pkgs/oneshot-cursors/default.nix
#
# Xcursor theme from OneShot's "World Machine" cursor sprite sheet. theme/
# is generated and vendored so a rebuild doesn't need the game installed:
# ~/documents/code/oneshot-twm-rice/scripts/gen_cursors.py slices the
# game's 112x48 cursor texture, upscales it nearest-neighbour to
# 16/24/32/48px and runs xcursorgen. Regenerate with `nix run .#gen-cursors`
# there and copy themes/oneshot-cursors/ back over theme/.
#
# Only 7 real shapes exist (left_ptr, pointer, grab, openhand, grabbing,
# move, not-allowed), plus symlinked aliases. Everything else (text caret,
# spinner, resize handles) comes from `Inherits=Adwaita` in index.theme
# rather than the stark X11 default.

{ lib, runCommandLocal }:

runCommandLocal "oneshot-cursors"
  {
    meta = {
      description = "Cursor theme from OneShot's World Machine desktop UI";
      # Game art, (c) Future Cat / Komodo. Fine for a personal rice, not
      # something to redistribute.
      license = lib.licenses.unfree;
      platforms = lib.platforms.all;
    };
  }
  ''
    mkdir -p "$out/share/icons"
    cp -a ${./theme} "$out/share/icons/Oneshot-Cursors"
  ''
