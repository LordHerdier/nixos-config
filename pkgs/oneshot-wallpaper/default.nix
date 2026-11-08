# pkgs/oneshot-wallpaper/default.nix
#
# The 1920x1080 "navigate" wallpaper (starfield with a blue trail) from
# OneShot's World Machine desktop. Extracted game art (c) Future Cat /
# Komodo, vendored so a rebuild doesn't need the game installed; re-extract
# with `nix run .#extract` in ~/documents/code/oneshot-twm-rice and copy
# out/the_world_machine/wallpaper/navigate.png over navigate.png here.
# (Not the game's default.png, which is a different wallpaper.)

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
