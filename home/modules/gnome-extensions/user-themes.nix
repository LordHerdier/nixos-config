# home/modules/gnome-extensions/user-themes.nix
#
# https://extensions.gnome.org/extension/19/user-themes/
#
# The supported way to replace GNOME Shell's compiled-in stylesheet. It
# looks for `<name>/gnome-shell/gnome-shell.css` under ~/.themes and each
# XDG_DATA_DIRS themes/ (so a theme package in home.packages works).
#
# An uninstalled `name` silently logs "loading default theme (Adwaita)";
# check for that first:
#
#   journalctl --user -b -u org.gnome.Shell@wayland.service | grep -i theme
#
# The theme name is set by whichever module ships the theme (on Apthos,
# home/modules/oneshot-gtk.nix).

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
