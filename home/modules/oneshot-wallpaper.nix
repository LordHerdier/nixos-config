# home/modules/oneshot-wallpaper.nix
#
# The OneShot World Machine starfield wallpaper (pkgs/oneshot-wallpaper),
# set as both the desktop background and the lock screen.
#
# picture-uri and picture-uri-dark both have to be set: GNOME picks
# between them based on the interface color-scheme, and oneshot-gtk.nix
# forces that to prefer-dark, so picture-uri alone would be ignored. The
# file:// prefix is required -- these keys are URIs, not paths, and a
# bare path is silently treated as "no wallpaper" rather than erroring.
#
# primary-color is what shows through in the letterboxed areas if the
# aspect ratio ever mismatches (the image is 1920x1080 and Apthos drives
# a 4K display at 200%, so "zoom" scales it up rather than tiling);
# black keeps that consistent with the theme instead of GNOME's default
# blue-grey.

{ pkgs, ... }:

let
  wallpaper = "file://${pkgs.oneshot-wallpaper}/share/wallpapers/oneshot/navigate.png";
in
{
  home.packages = [ pkgs.oneshot-wallpaper ];

  dconf.settings = {
    "org/gnome/desktop/background" = {
      picture-uri = wallpaper;
      picture-uri-dark = wallpaper;
      picture-options = "zoom";
      primary-color = "#000000";
    };

    "org/gnome/desktop/screensaver" = {
      picture-uri = wallpaper;
      picture-options = "zoom";
      primary-color = "#000000";
    };
  };
}
