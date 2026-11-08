# home/modules/oneshot-cursors.nix
#
# The OneShot World Machine cursor theme (pkgs/oneshot-cursors) for a
# GNOME session. Don't import alongside hyprland/40-design.nix: both set
# home.pointerCursor.

{ pkgs, ... }:

let
  cursorSize = 24;
in
{
  home.pointerCursor = {
    enable = true;
    package = pkgs.oneshot-cursors;
    name = "Oneshot-Cursors";
    size = cursorSize;
  };

  # GNOME ignores XCURSOR_* from home.pointerCursor: mutter and
  # gnome-settings-daemon use this dconf value (which also beats gtk's
  # settings.ini).
  dconf.settings."org/gnome/desktop/interface" = {
    cursor-theme = "Oneshot-Cursors";
    cursor-size = cursorSize;
  };
}
