# pkgs/oneshot-wallpaper/default.nix
#
# The 1920x1080 "navigate" wallpaper from OneShot's World Machine desktop
# -- a near-black starfield with a glowing blue trail. Extracted game art
# (c) Future Cat / Komodo, vendored so a rebuild doesn't need the game
# installed; re-extract with `nix run .#extract` in
# ~/documents/code/oneshot-twm-rice, then copy
# out/the_world_machine/wallpaper/navigate.png over navigate.png here.
#
# Note this is specifically navigate.png, NOT the game's default.png --
# that one is a different in-fiction wallpaper (purple monitors/clover
# motif), still black and purple but not the starfield.
#
# Ships at native 1920x1080 with no upscaling; the game's wallpapers are
# already full resolution, unlike its pixel-art icons and cursors.

{ lib, runCommandLocal }:

runCommandLocal "oneshot-wallpaper"
  {
    meta = {
      description = "OneShot World Machine starfield wallpaper (1920x1080)";
      license = lib.licenses.unfree;
      platforms = lib.platforms.all;
    };
  }
  ''
    mkdir -p "$out/share/wallpapers/oneshot"
    cp ${./navigate.png} "$out/share/wallpapers/oneshot/navigate.png"
  ''
