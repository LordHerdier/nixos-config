# pkgs/oneshot-cursors/default.nix
#
# Xcursor theme built from OneShot's "World Machine" fake-OS cursor sprite
# sheet. theme/ is generated output, not hand-authored: the game ships the
# cursors as one 112x48 XNB texture (7 states x 3 rows), and
# ~/documents/code/oneshot-twm-rice/scripts/gen_cursors.py slices row 0,
# upscales it nearest-neighbour to 16/24/32/48px and runs xcursorgen over
# the result. It's vendored here so a rebuild doesn't need the game
# installed; regenerate with `nix run .#gen-cursors` in that repo and copy
# themes/oneshot-cursors/ back over theme/.
#
# Only 7 real shapes exist (left_ptr, pointer, grab, openhand, grabbing,
# move, not-allowed) plus alias names as symlinks. Everything the game
# never drew -- text caret, wait spinner, resize handles -- resolves
# through `Inherits=Adwaita` in index.theme instead of falling back to the
# stark X11 default.

{ lib, runCommandLocal }:

runCommandLocal "oneshot-cursors" {
  meta = {
    description = "Cursor theme from OneShot's World Machine desktop UI";
    # Game art, (c) Future Cat / Komodo. Fine for a personal rice, not
    # something to redistribute.
    license = lib.licenses.unfree;
    platforms = lib.platforms.all;
  };
} ''
  mkdir -p "$out/share/icons"
  cp -a ${./theme} "$out/share/icons/Oneshot-Cursors"
''
