# home/modules/gnome-extensions/user-themes.nix
#
# https://extensions.gnome.org/extension/19/user-themes/
#
# GNOME Shell's own stylesheet ships inside a GResource bundle compiled
# into gnome-shell, and nothing in Settings or dconf can point the Shell
# at a different one -- org/gnome/desktop/interface accent-color only
# picks one of nine fixed hues, and gtk-theme doesn't reach the Shell at
# all. This extension is the supported way to override it: it looks for
# `<dir>/<name>/gnome-shell/gnome-shell.css` under ~/.themes and every
# XDG_DATA_DIRS entry's themes/ (so ~/.nix-profile/share/themes, where
# a theme package in home.packages lands), and hands the match to
# Main.setThemeStylesheet().
#
# Setting `name` to a theme that isn't installed is a silent no-op: the
# extension logs "loading default theme (Adwaita)" and the Shell stays
# stock. If a shell theme doesn't appear to apply, that journal line is
# the first thing to check:
#
#   journalctl --user -b -u org.gnome.Shell@wayland.service | grep -i theme
#
# The theme name itself isn't set here -- whichever module ships the
# theme package owns it, so the package and the name that selects it
# stay in one place. On Apthos that's home/modules/oneshot-gtk.nix.

{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.gnome-extensions.user-themes;
in
{
  options.my.gnome-extensions.user-themes.enable =
    mkEnableOption "the User Themes GNOME Shell extension";

  config = mkIf cfg.enable {
    my.gnome-extensions.extensions = [ pkgs.gnomeExtensions.user-themes ];
  };
}
