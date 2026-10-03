# home/modules/oneshot-icons.nix
#
# The OneShot World Machine icon theme (pkgs/oneshot-icons), wired up for
# a GNOME session. Same dconf-not-settings.ini reasoning as its siblings
# oneshot-cursors.nix and oneshot-gtk.nix -- gnome-settings-daemon pushes
# the dconf value at GTK apps and overrides anything in settings.ini.
#
# Worth knowing what this does and doesn't change: the theme only defines
# OneShot's own icon names, so almost every icon you actually see (app
# icons, Nautilus, the Settings sidebar) still comes from Adwaita via the
# theme's Inherits chain. Selecting it is mostly a prerequisite for
# referencing the game's icons by name from our own launchers, not a
# desktop-wide icon swap. If icons start rendering as missing-image
# glyphs, check that index.theme still inherits Adwaita rather than bare
# hicolor.

{ pkgs, ... }:

{
  home.packages = [ pkgs.oneshot-icons ];

  dconf.settings."org/gnome/desktop/interface".icon-theme = "Oneshot-Icons";
}
