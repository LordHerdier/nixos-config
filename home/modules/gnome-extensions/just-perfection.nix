# home/modules/gnome-extensions/just-perfection.nix
#
# https://extensions.gnome.org/extension/3843/just-perfection/
#
# Individually toggleable Shell tweaks; schema defaults reproduce stock
# GNOME. Int-valued keys are offset enums (`animation`: 0 disabled,
# 1 default, 2+ faster; `panel-size`: 0 = Shell theme, 1-64 px), so check
# the gschema before adding one:
#
#   grep -A3 'name="<key>"' \
#     "$(nix build --no-link --print-out-paths nixpkgs#gnomeExtensions.just-perfection)"/share/gnome-shell/extensions/just-perfection-desktop@just-perfection/schemas/*.gschema.xml
#
# Only non-default keys are set; the rest stay editable in the
# extension's preferences.

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
      # Focus a window demanding attention (Alt-Tab, notification click)
      # instead of leaving it flashing in the dock.
      window-demands-attention-focus = true;

      workspace-wrap-around = true;

      # startup-status left at its default (overview on login), like
      # dash-to-dock's disable-overview-on-startup.
    };
  };
}
