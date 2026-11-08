# home/modules/theme/palettes/gruvbox-nightfox.nix
#
# The gruvbox-derived palette nvf's nightfox setup was written for.
# Nightfox's base/bright pairs map onto the ANSI 16 one-to-one
# (`red.base` = red, `red.bright` = brightRed; bg0/fg1 = bg/fg).
#
# Not gruvbox stock: bg is #181921 (cooler and darker than dark0
# #282828) and several brights lean brighter/greener. Kept as-is.
#
# brightBlack is gruvbox's gray #928374. nvf's nightfox palette doesn't
# read it (paletteLua passes a single `black`), but the default roles
# (muted, surfaceAlt, borderInactive, selectionBg) do.

{
  name = "gruvbox-nightfox";
  polarity = "dark";

  palette = {
    bg = "#181921"; # nightfox bg0
    fg = "#ebdbb2"; # nightfox fg1

    black = "#1d2021";
    red = "#cc241d";
    green = "#98971a";
    yellow = "#d79921";
    blue = "#458588";
    magenta = "#b16286";
    cyan = "#689d6a";
    white = "#a89984";

    brightBlack = "#928374"; # see header
    brightRed = "#f42c3e";
    brightGreen = "#b8bb26";
    brightYellow = "#fabd2f";
    brightBlue = "#99c6ca";
    brightMagenta = "#d3869b";
    brightCyan = "#7ec16e";
    brightWhite = "#ebdbb2";
  };

  roles = {
    # Neovim WinSeparator (10-theme.nix).
    border = "#458588";
    accent = "#458588";
  };
}
