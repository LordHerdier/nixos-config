# home/modules/gnome-extensions/dash-to-dock.nix
#
# Vanilla GNOME only shows the dash inside the Activities overview.
# dash-to-dock pins it to the desktop as a persistent taskbar/dock.

{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.gnome-extensions.dash-to-dock;
in
{
  options.my.gnome-extensions.dash-to-dock.enable =
    mkEnableOption "the dash-to-dock GNOME Shell extension";

  config = mkIf cfg.enable {
    my.gnome-extensions.extensions = [ pkgs.gnomeExtensions.dash-to-dock ];

    dconf.settings."org/gnome/shell/extensions/dash-to-dock" = {
      # Full-width bottom panel, icons centred (always-center-icons only
      # applies with extend-height).
      dock-position = "BOTTOM";
      extend-height = true;
      always-center-icons = true;
      multi-monitor = true;

      dock-fixed = true;
      autohide = false;
      intellihide = true;

      # A cap; icons still shrink when the dash outgrows the screen.
      dash-max-icon-size = 32;
      custom-theme-shrink = true;

      show-favorites = true;
      show-running = true;

      # Keep the overview on login: it's how to reach unpinned apps.
      disable-overview-on-startup = false;

      scroll-action = "switch-workspace";

      # One segment per open window instead of a single dot.
      custom-theme-customize-running-dots = true;
      running-indicator-style = "SEGMENTED";

      # Dock background fades in only when a window is near/behind it.
      transparency-mode = "DYNAMIC";
    };
  };
}
