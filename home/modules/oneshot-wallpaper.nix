# home/modules/oneshot-wallpaper.nix
#
# The OneShot World Machine starfield wallpaper (pkgs/oneshot-wallpaper),
# set as both the desktop background and the lock screen.
#
# picture-uri-dark is needed too: oneshot-gtk.nix sets prefer-dark. The
# file:// prefix is required; a bare path silently means no wallpaper.
#
# primary-color fills any letterboxing, from the same palette as the GTK
# theme rather than GNOME's default blue-grey.

{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkOption types;

  cfg = config.my.oneshot-wallpaper;

  wallpaper = "file://${pkgs.oneshot-wallpaper}/share/wallpapers/oneshot/navigate.png";
in
{
  options.my.oneshot-wallpaper = {
    palette = mkOption {
      type = types.enum (lib.attrNames config.my.theme.palettes);
      # Pinned like my.oneshot-gtk.palette; separate so neither module
      # depends on the other.
      default = "oneshot";
      description = "Which my.theme palette the letterbox fill comes from.";
    };
  };

  config = {
    home.packages = [ pkgs.oneshot-wallpaper ];

    dconf.settings = {
      "org/gnome/desktop/background" = {
        picture-uri = wallpaper;
        picture-uri-dark = wallpaper;
        picture-options = "zoom";
        primary-color = config.my.theme.palettes.${cfg.palette}.palette.bg;
      };

      "org/gnome/desktop/screensaver" = {
        picture-uri = wallpaper;
        picture-options = "zoom";
        primary-color = config.my.theme.palettes.${cfg.palette}.palette.bg;
      };
    };
  };
}
