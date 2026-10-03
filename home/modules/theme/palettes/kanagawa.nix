# home/modules/theme/palettes/kanagawa.nix
#
# Kanagawa (rebelot/kanagawa.nvim), dark. Transcribed verbatim from what
# tmux and spotify-player were each carrying their own copy of, so
# switching them onto this file is a no-op.
#
# The two sumiInk shades are the reason `surfaceAlt` is pinned below:
# tmux uses sumiInk0 (#16161d) for the status bar and sumiInk4 (#2a2a37)
# for pane borders, and neither is the brightBlack the generic role
# default would pick.

{
  name = "kanagawa";
  polarity = "dark";

  palette = {
    bg = "#1f1f28"; # sumiInk3
    fg = "#dcd7ba"; # fujiWhite

    black = "#16161d"; # sumiInk0
    red = "#c34043"; # autumnRed
    green = "#98bb6c"; # springGreen
    yellow = "#e6c384"; # carpYellow
    blue = "#7e9cd8"; # crystalBlue
    magenta = "#d27e99"; # sakuraPink
    cyan = "#7fb4ca"; # springBlue
    white = "#c8c093"; # oldWhite

    brightBlack = "#727169"; # fujiGray
    brightRed = "#e82424"; # samuraiRed
    brightGreen = "#76946a"; # autumnGreen
    brightYellow = "#ff9e3b"; # roninYellow
    brightBlue = "#7fb4ca"; # springBlue
    brightMagenta = "#957fb8"; # oniViolet
    brightCyan = "#7aa89f"; # waveAqua2
    brightWhite = "#dcd7ba"; # fujiWhite
  };

  roles = {
    # springBlue, not crystalBlue: this is the hue tmux already used for
    # the active pane border, the current window and the clock.
    accent = "#7fb4ca";
    accentFg = "#16161d";
    border = "#7fb4ca";

    surface = "#16161d"; # status bar / popup background
    surfaceAlt = "#2a2a37"; # sumiInk4 -- inactive borders, fzf cursorline
  };
}
