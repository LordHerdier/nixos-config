# home/modules/theme/palettes/kanagawa.nix
#
# Kanagawa (rebelot/kanagawa.nvim), dark.
#
# `surface`/`surfaceAlt` are pinned to sumiInk0 (#16161d) and sumiInk4
# (#2a2a37) rather than the role defaults (black/brightBlack).

{
  name = "kanagawa";
  polarity = "dark";

  # NOTE: green/brightGreen are swapped relative to upstream kanagawa,
  # whose bright slot (autumnGreen) is darker than the base
  # (springGreen). Terminals and nightfox expect bright to be brighter.

  palette = {
    bg = "#1f1f28"; # sumiInk3
    fg = "#dcd7ba"; # fujiWhite

    black = "#16161d"; # sumiInk0
    red = "#c34043"; # autumnRed
    green = "#76946a"; # autumnGreen
    yellow = "#e6c384"; # carpYellow
    blue = "#7e9cd8"; # crystalBlue
    magenta = "#d27e99"; # sakuraPink
    cyan = "#7fb4ca"; # springBlue
    white = "#c8c093"; # oldWhite

    brightBlack = "#727169"; # fujiGray
    brightRed = "#e82424"; # samuraiRed
    brightGreen = "#98bb6c"; # springGreen
    brightYellow = "#ff9e3b"; # roninYellow
    brightBlue = "#7fb4ca"; # springBlue
    brightMagenta = "#957fb8"; # oniViolet
    brightCyan = "#7aa89f"; # waveAqua2
    brightWhite = "#dcd7ba"; # fujiWhite
  };

  roles = {
    # springBlue, not crystalBlue (tmux's long-standing accent hue).
    accent = "#7fb4ca";
    accentFg = "#16161d";
    border = "#7fb4ca";

    surface = "#16161d"; # status bar / popup background
    surfaceAlt = "#2a2a37"; # sumiInk4 -- inactive borders, fzf cursorline

    # waveBlue2, kanagawa.nvim's own Visual. The role default (fujiGray)
    # is unreadable behind light text.
    selectionBg = "#2d4f67";

    # springGreen: the vivid green, which the swap above moved off the
    # base slot the role default reads.
    success = "#98bb6c";
  };
}
