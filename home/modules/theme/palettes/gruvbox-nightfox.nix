# home/modules/theme/palettes/gruvbox-nightfox.nix
#
# The gruvbox-derived palette nvf feeds to nightfox, transcribed from
# home/modules/nvf/10-theme.nix.
#
# Nightfox addresses colors as base/bright pairs, which maps onto the
# ANSI 16 one-to-one -- `red.base` is `red`, `red.bright` is `brightRed`.
# bg0/fg1 in nightfox's terms are bg/fg here.
#
# Two values are not gruvbox stock: bg is #181921 (a cooler, darker
# background than gruvbox dark0 #282828) and several brights are pulled
# toward brighter/greener variants. Kept as-is.
#
# brightBlack is gruvbox's own gray #928374. Nightfox was never given a
# black.bright, so nothing reads this yet; it exists because the palette
# schema requires all 16, and leaving it out would mean any future
# consumer of this palette gets an eval error rather than a color.

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

    brightBlack = "#928374"; # see header -- unused by nightfox
    brightRed = "#f42c3e";
    brightGreen = "#b8bb26";
    brightYellow = "#fabd2f";
    brightBlue = "#99c6ca";
    brightMagenta = "#d3869b";
    brightCyan = "#7ec16e";
    brightWhite = "#ebdbb2";
  };

  roles = {
    # The window separator color 10-theme.nix sets by hand.
    border = "#458588";
    accent = "#458588";
  };
}
