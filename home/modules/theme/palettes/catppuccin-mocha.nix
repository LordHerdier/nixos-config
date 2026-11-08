# home/modules/theme/palettes/catppuccin-mocha.nix
#
# Catppuccin Mocha as kitty was configured, which is not stock Mocha:
#
#   bg            #161926, not Mocha's base #1e1e2e (darker blue-black).
#   selectionBg   #44475a is Dracula's selection, not Mocha's surface2.
#   cursor/url/
#   borderInactive  plain greys and a Windows-ish link blue, off-palette.
#
# Kept deliberately; candidates to move back onto palette colors.

{
  name = "catppuccin-mocha";
  polarity = "dark";

  palette = {
    bg = "#161926"; # custom, see above
    fg = "#cdd6f4"; # text

    black = "#45475a"; # surface1
    red = "#f38ba8"; # red
    green = "#a6e3a1"; # green
    yellow = "#f9e2af"; # yellow
    blue = "#89b4fa"; # blue
    magenta = "#f5c2e7"; # pink
    cyan = "#94e2d5"; # teal
    white = "#bac2de"; # subtext1

    brightBlack = "#585b70"; # surface2
    brightRed = "#f38ba8";
    brightGreen = "#a6e3a1";
    brightYellow = "#f9e2af";
    brightBlue = "#89b4fa";
    brightMagenta = "#f5c2e7";
    brightCyan = "#94e2d5";
    brightWhite = "#a6adc8"; # subtext0
  };

  roles = {
    accent = "#cba6f7"; # mauve -- in Mocha, but not in the ANSI 16
    accentFg = "#161926";
    border = "#cba6f7";

    surface = "#45475a";
    surfaceAlt = "#585b70";

    # off-palette, see header
    borderInactive = "#777777";
    selectionBg = "#44475a";
    cursor = "#bbbbbb";
    url = "#0078d7";
  };
}
