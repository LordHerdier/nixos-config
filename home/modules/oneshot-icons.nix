# home/modules/oneshot-icons.nix
#
# The OneShot World Machine icon theme (pkgs/oneshot-icons) for a GNOME
# session, set via dconf like its oneshot-* siblings (gnome-settings-daemon
# overrides settings.ini).
#
# The theme only defines OneShot's own icon names; almost everything else
# still comes from Adwaita via Inherits. If icons render as missing-image
# glyphs, check index.theme still inherits Adwaita, not bare hicolor.

{ pkgs, ... }:

{
  home.packages = [ pkgs.oneshot-icons ];

  dconf.settings."org/gnome/desktop/interface".icon-theme = "Oneshot-Icons";
}
