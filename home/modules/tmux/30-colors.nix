# home/modules/tmux/30-colors.nix
#
# Colors come from `my.theme`, via the `tmux` runtime fragment
# (home/modules/theme/runtime.nix) so `theme-set` can recolour a running
# server. The tm_* shell variables are named for the role, not the hue.
# ./20-status-and-titles.nix reads its colors through the @tm_* user
# options the fragment sets.

{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Window labels. While a focused neovim owns the bar (@nvim_active, see
  # ../nvf/plugins/96-tpipeline.nix) labels shrink to the index; the
  # bell/zoom markers survive both forms.
  markers = "#{?window_bell_flag,!,}#{?window_zoomed_flag,Z,}";
  gap = "#{?#{||:#{window_bell_flag},#{window_zoomed_flag}}, ,}";
  named = " #I #W${gap}${markers} ";
  numbered = " #I${markers} ";
  # Truthiness rather than `== 1`, so an unset option gives full labels.
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

      # Read as #{@tm_*} by ./20-status-and-titles.nix.
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

      # Neutral base style: `#[default]` resets to it after the session
      # chunk, and anything louder would bleed across the embedded neovim
      # statusline. The session chunk carries its colours inline.
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

    # Reset at source time: the option outlives the neovim that set it,
    # and a stale 1 would keep the window list collapsed.
    set -g @nvim_active 0

    setw -g window-status-format "${windowLabel}"
    setw -g window-status-current-format "${windowLabel}"
  '';
}
