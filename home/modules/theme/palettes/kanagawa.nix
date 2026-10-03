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

  # NOTE: green/brightGreen are swapped relative to upstream kanagawa's
  # ANSI mapping, which has the bright slot (autumnGreen #76946a) darker
  # than the base one (springGreen #98bb6c). Terminals and nightfox both
  # expect bright to be the brighter of the pair, so the inversion read
  # as a bug everywhere it showed up.

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
    # springBlue, not crystalBlue: this is the hue tmux already used for
    # the active pane border, the current window and the clock.
    accent = "#7fb4ca";
    accentFg = "#16161d";
    border = "#7fb4ca";

    surface = "#16161d"; # status bar / popup background
    surfaceAlt = "#2a2a37"; # sumiInk4 -- inactive borders, fzf cursorline

    # waveBlue2, which is what kanagawa.nvim itself uses for Visual. The
    # generic role default would pick fujiGray, and a grey selection
    # behind light text is unreadable.
    selectionBg = "#2d4f67";

    # springGreen, not the base green the role default would take. A
    # "this worked" marker wants the vivid green, and the green/
    # brightGreen swap above moved that off the base slot.
    success = "#98bb6c";
  };
}
