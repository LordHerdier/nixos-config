# home/modules/theme/palettes/oneshot.nix
#
# OneShot's in-fiction "World Machine" OS, as implemented by
# pkgs/oneshot-gtk-theme: pure black surfaces, one saturated purple, no
# gradients, inverted selection. Values read off the stylesheets.
#
# This is a UI-chrome palette, not a terminal one -- nothing in the
# OneShot rice colors a terminal. The game UI has exactly one hue, so the
# ANSI slots are collapsed onto the accent, which is the same choice
# gtk-3.0/gtk.css already makes for success/warning/error. The `roles`
# below are the part that actually carries meaning here.
#
# Consumed by home/modules/oneshot-gtk.nix and oneshot-wallpaper.nix,
# which hand these six values to pkgs/oneshot-gtk-theme. The six that
# matter are bg, fg, accent, accentDim, accentMuted (muted) and
# surfaceAlt -- those are every distinct color the stylesheets use.

{
  name = "oneshot";
  polarity = "dark";

  palette = {
    bg = "#000000";
    fg = "#cbb8ff"; # the accent lightened for standalone text

    black = "#000000";
    red = "#9664ff";
    green = "#9664ff";
    yellow = "#9664ff";
    blue = "#9664ff";
    magenta = "#9664ff";
    cyan = "#9664ff";
    white = "#cbb8ff";

    brightBlack = "#4a3d66"; # dimmest purple -- disabled text, separators
    brightRed = "#cbb8ff";
    brightGreen = "#cbb8ff";
    brightYellow = "#cbb8ff";
    brightBlue = "#cbb8ff";
    brightMagenta = "#cbb8ff";
    brightCyan = "#cbb8ff";
    brightWhite = "#cbb8ff";
  };

  roles = {
    accent = "#9664ff";
    accentFg = "#000000"; # inverted selection: accent fill, black text
    accentDim = "#6442a5"; # pressed/destructive fill
    border = "#9664ff";
    borderInactive = "#4a3d66";

    surface = "#000000";
    surfaceAlt = "#1a1a1a"; # the one non-black surface: GTK2 bg[PRELIGHT]
    muted = "#4a3d66";

    selectionBg = "#9664ff";
    selectionFg = "#000000";

    # One hue means the semantic colors cannot signal by hue; destructive
    # stays distinguishable by being the dim variant instead.
    error = "#6442a5";
    warning = "#6442a5";
    success = "#9664ff";
  };
}
