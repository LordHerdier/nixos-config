# home/modules/theme/palettes/halloween.nix
#
# Halloween palette sampled off ~/Pictures/iced-charantinator-halloween-chara.jpg
# (art by ICED): a purple-black town silhouetted against an orange
# dusk sky, lit by a yellow crescent moon and yellow windows.
#
# Surfaces are the image's dominant shadow purples (#120c16, #24121a);
# the accent is the dusk sky orange. The secondary chrome -- inactive
# borders, selection, cursor, muted text -- leans on the reds (devil
# eyes, brick wall) so the scheme is not just orange-on-purple. Hues the image only has
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
    red = "#f0263a"; # devil eyes
    green = "#8fb36a";
    yellow = "#fece22"; # lit windows
    blue = "#7f86b8"; # skull slate, pushed toward blue
    magenta = "#c0507a"; # plum boots, lifted
    cyan = "#489e8f"; # skull eye glow
    white = "#cdbfb5"; # skull highlight

    brightBlack = "#7a5662"; # red-leaning plum grey -- comments
    brightRed = "#ff5a64";
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
    borderInactive = "#6a1f2b"; # brick wall, pushed toward blood red

    surface = "#1b1020";
    surfaceAlt = "#3a1420"; # tmux pane borders
    muted = "#a4505e"; # dusty red -- tmux status text, bar separators

    # Dark crimson. Dark enough for fg to stay readable on it, and red
    # so it does not read as another surface purple.
    selectionBg = "#5c1624";

    cursor = "#ff2a3a"; # the devil eyes
    url = "#6fd0bf";

    # The accent is orange, so warning takes the window yellow instead
    # of colliding with it.
    warning = "#fece22";
    success = "#8fb36a";
    error = "#f0263a";
  };
}
