# home/modules/tmux/30-colors.nix
#
# Colors come from `my.theme` (see home/modules/theme). The shell
# variables below are kept as an indirection layer inside the generated
# tmux.conf -- they make the `set -g` lines readable and they are named
# for the role, not the hue, so swapping the palette does not leave the
# config lying about what it is doing.
#
# Every color line lives in the `tmux` fragment (home/modules/theme/runtime.nix),
# sourced from the active palette, so `theme-set` can recolour a running
# server. What it leaves behind is layout. The status lines in
# ./20-status-and-titles.nix reach the two colors they need through the
# @tm_* user options the fragment sets, rather than through hex baked in.

{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Window labels. A focused neovim hands its whole lualine to this bar
  # (see ../nvf/plugins/96-tpipeline.nix), which leaves the window list
  # short of room, so while @nvim_active is set the labels drop their
  # names and keep only the index. The bell/zoom markers survive both
  # forms -- they are the part you cannot afford to miss.
  markers = "#{?window_bell_flag,!,}#{?window_zoomed_flag,Z,}";
  gap = "#{?#{||:#{window_bell_flag},#{window_zoomed_flag}}, ,}";
  named = " #I #W${gap}${markers} ";
  numbered = " #I${markers} ";
  # Truthiness rather than `==` with 1: this reads correctly when the
  # option is unset, 0, or 1, so a tmux that has never seen a neovim
  # still gets full labels.
  windowLabel = "#{?#{@nvim_active},${numbered},${named}}";

  colours =
    theme:
    let
      p = theme.palette;
      r = theme.roles;
    in
    ''
      ##### Colors -- ${theme.name} (my.theme) #####

      tm_surface="${r.surface}"
      tm_surface_alt="${r.surfaceAlt}"
      tm_muted="${r.muted}"
      tm_accent="${r.accent}"
      tm_accent_fg="${r.accentFg}"
      tm_attention="${p.yellow}"

      # The status lines are laid out in ./20-status-and-titles.nix and
      # read these as #{@tm_*} so the colors stay here.
      set -g @tm_surface "$tm_surface"
      set -g @tm_attention "$tm_attention"
      set -g @tm_magenta "${p.magenta}"

      # session dots plugin color
      set -g @session-dots-color "$tm_accent"

      set -g window-style "fg=default,bg=default"
      set -g window-active-style "fg=default,bg=default"

      set -g pane-border-style "fg=$tm_surface_alt"
      set -g pane-active-border-style "fg=$tm_accent"
      set -g pane-border-lines "single"

      set -g display-panes-colour "$tm_accent"
      set -g display-panes-active-colour "$tm_accent"

      set -g status-style "fg=$tm_muted,bg=$tm_surface"

      set -g message-style "fg=$tm_surface,bg=$tm_attention,bold"
      set -g message-command-style "fg=$tm_attention,bg=$tm_surface,bold"
      set -g mode-style "fg=$tm_surface,bg=$tm_attention,bold"

      setw -g window-status-style "fg=$tm_muted,bg=$tm_surface"
      setw -g window-status-current-style "fg=$tm_accent_fg,bg=$tm_accent,bold"
      setw -g window-status-activity-style "fg=default,bg=default,underscore"
      setw -g window-status-bell-style "fg=$tm_attention,bg=default,blink,bold"

      # Both halves of the bar carry a neovim statusline (see
      # ../nvf/plugins/96-tpipeline.nix), so their base style has to be the
      # neutral one -- it is what `#[default]` resets back to after the
      # session chunk, and painting the whole left yellow would bleed that
      # colour across the embedded statusline. The session chunk therefore
      # carries its colours inline in 20-status-and-titles.nix.
      set -g status-left-style "fg=$tm_muted,bg=$tm_surface"
      set -g status-right-style "fg=$tm_muted,bg=$tm_surface"

      set -g clock-mode-colour "$tm_accent"
    '';
in
{
  my.theme.fragments.tmux = {
    file = "tmux.conf";
    wal = true;
    render = colours;
    # Every server, not just the one this shell is in. Stale sockets just
    # fail to connect.
    reload = ''
      for sock in "''${TMUX_TMPDIR:-/tmp}/tmux-$(id -u)"/*; do
        [ -S "$sock" ] && tmux -S "$sock" source-file "${config.my.theme.runtime.active}/tmux.conf"
      done
    '';
    runtimeInputs = [ pkgs.tmux ];
  };

  programs.tmux.extraConfig = lib.mkAfter ''
    ##### Colors #####

    source-file -q ${config.my.theme.runtime.active}/tmux.conf

    # Declare the window-label flag off at source time. It is a session
    # option, so it outlives the neovim that set it: without this reset
    # a server that still remembers a long-gone neovim would keep the
    # window list collapsed forever.
    set -g @nvim_active 0

    setw -g window-status-format "${windowLabel}"
    setw -g window-status-current-format "${windowLabel}"
  '';
}
