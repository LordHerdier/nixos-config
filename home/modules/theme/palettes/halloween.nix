# home/modules/theme/palettes/halloween.nix
#
# Halloween palette sampled off ~/Pictures/iced-charantinator-halloween-chara.jpg
# (art by ICED): a purple-black town silhouetted against an orange
# dusk sky, lit by a yellow crescent moon and yellow windows.
#
# Surfaces are the image's dominant shadow purples (#120c16, #24121a,
# #2e1425); the accent is the dusk sky orange. Hues the image only has
# in small spots are taken from them: red from the devil eyes, cyan
# from the skull's eye glow, magenta from the plum boots and pink shirt.
# Green and blue barely exist in the picture, so they are dusky picks
# chosen to stay distinct from cyan and from each other on the purple
# background.

{
  name = "halloween";
  polarity = "dark";

  palette = {
    bg = "#120c16"; # shadowed buildings
    fg = "#f0dcc4"; # warm skin/parchment

    black = "#24121a";
    red = "#e8323a"; # devil eyes, softened
    green = "#8fb36a";
    yellow = "#fece22"; # lit windows
    blue = "#7f86b8"; # skull slate, pushed toward blue
    magenta = "#c0507a"; # plum boots, lifted
    cyan = "#489e8f"; # skull eye glow
    white = "#cdbfb5"; # skull highlight

    brightBlack = "#6e5a6a"; # muted plum grey -- comments, separators
    brightRed = "#ff5a5f";
    brightGreen = "#b2d68a";
    brightYellow = "#fdf04a"; # crescent moon
    brightBlue = "#a9aed8";
    brightMagenta = "#da84a1"; # pink shirt
    brightCyan = "#6fd0bf";
    brightWhite = "#fff1dd";
  };

  roles = {
    accent = "#e68f03"; # dusk sky orange
    accentFg = "#120c16";
    accentDim = "#a15806"; # the sky further from the horizon
    border = "#e68f03";
    borderInactive = "#481d2a"; # brick wall

    surface = "#1b1020";
    surfaceAlt = "#2e1425";
    muted = "#6e5a6a";

    # Burnt top-of-sky brown. Dark enough for fg to stay readable on it,
    # and warm so it does not read as another surface purple.
    selectionBg = "#682d11";

    cursor = "#fece22";
    url = "#6fd0bf";

    # The accent is orange, so warning takes the window yellow instead
    # of colliding with it.
    warning = "#fece22";
    success = "#8fb36a";
    error = "#e8323a";
  };
}
