# home/profiles/desktop-gnome.nix

{ pkgs, ... }:

{
  imports = [
    ../modules/desktop-packages.nix
    ../modules/kitty.nix
    ../modules/steam.nix
    ../modules/games.nix
  ];

  # font-rendering.nix isn't needed here: it exists to hand GTK/Qt apps
  # antialiasing/hinting settings via GSettings/XSettings because
  # Hyprland has no session daemon to push them. GNOME's own
  # gnome-settings-daemon already does this.

  my.kitty.enable = true;

  # Vanilla GNOME only shows the dash inside the Activities overview.
  # dash-to-dock pins it to the desktop as a persistent taskbar/dock.
  home.packages = [ pkgs.gnomeExtensions.dash-to-dock ];

  dconf.settings = {
    "org/gnome/shell".enabled-extensions = [ "dash-to-dock@micxgx.gmail.com" ];
    "org/gnome/shell/extensions/dash-to-dock" = {
      # Position and reach: a full-width bar glued to the bottom edge
      # (panel mode), with the icons themselves centred rather than
      # left-aligned. always-center-icons only has an effect while
      # extend-height is on.
      dock-position = "BOTTOM";
      extend-height = true;
      always-center-icons = true;
      multi-monitor = true;

      # Visibility. dock-fixed keeps it on screen; intellihide is what
      # pulls it out of the way of a window that would overlap it.
      dock-fixed = true;
      autohide = false;
      intellihide = true;

      # Icons. 32px is a cap, not a fixed size — the dock still shrinks
      # icons below this when the dash outgrows the screen width.
      dash-max-icon-size = 32;
      custom-theme-shrink = true;

      show-favorites = true;
      show-running = true;

      # The overview is still the way to find an app that isn't pinned,
      # so keep it on login rather than dropping straight to a bare
      # desktop. The key is phrased negatively in the schema.
      disable-overview-on-startup = false;

      scroll-action = "switch-workspace";

      # Per-window counter under each icon instead of the single default
      # dot, so the dock shows how many windows an app has open.
      custom-theme-customize-running-dots = true;
      running-indicator-style = "SEGMENTED";

      # Dock background fades in only when a window is near/behind it.
      transparency-mode = "DYNAMIC";
    };
  };
}
