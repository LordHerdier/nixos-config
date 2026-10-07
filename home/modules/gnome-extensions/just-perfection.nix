# home/modules/gnome-extensions/just-perfection.nix
#
# https://extensions.gnome.org/extension/3843/just-perfection/
#
# A pile of individually-toggleable Shell tweaks: hide or resize bits of
# the top panel, the dash, the overview, the OSD, change animation speed
# and so on. Everything it does is off-by-default in the sense that the
# schema's defaults reproduce stock GNOME, so installing it changes
# nothing until a key below is set -- it's a box of knobs, not a theme.
#
# Keys live under org/gnome/shell/extensions/just-perfection. Note the
# int-valued ones are enums with an offset convention rather than plain
# measurements (`animation`: 0 disabled, 1 default speed, 2+ faster;
# `panel-size`: 0 means "use the Shell theme", 1-64 is pixels), so
# "0 means off" is not a safe assumption -- check the gschema before
# adding one:
#
#   grep -A3 'name="<key>"' \
#     "$(nix build --no-link --print-out-paths nixpkgs#gnomeExtensions.just-perfection)"/share/gnome-shell/extensions/just-perfection-desktop@just-perfection/schemas/*.gschema.xml
#
# Only keys that differ from the stock default are set here. Anything
# not listed stays at GNOME's own behaviour and remains editable from
# the extension's own preferences dialog, since Home Manager only writes
# the keys it manages.

{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.gnome-extensions.just-perfection;
in
{
  options.my.gnome-extensions.just-perfection.enable =
    mkEnableOption "the Just Perfection GNOME Shell extension";

  config = mkIf cfg.enable {
    my.gnome-extensions.extensions = [ pkgs.gnomeExtensions.just-perfection ];

    dconf.settings."org/gnome/shell/extensions/just-perfection" = {
      # Alt-Tab and clicking a notification should jump straight to the
      # window instead of leaving it flashing in the dock waiting for a
      # second click. GNOME's default here is deliberately conservative
      # about focus stealing; with a bottom dock the flashing icon is
      # easy to miss entirely.
      window-demands-attention-focus = true;

      # Scrolling/switching past the last workspace lands back on the
      # first instead of stopping dead.
      workspace-wrap-around = true;

      # startup-status is intentionally left at its default (1 =
      # overview). The dock's disable-overview-on-startup is set the
      # same way for the same reason: the overview is still how you
      # reach an app that isn't pinned, so it's worth seeing at login.
    };
  };
}
