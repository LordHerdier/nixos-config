# home/modules/tmux/30-colors.nix
#
# Colors come from `my.theme` (see home/modules/theme). The shell
# variables below are kept as an indirection layer inside the generated
# tmux.conf -- they make the `set -g` lines readable and they are named
# for the role, not the hue, so swapping the palette does not leave the
# config lying about what it is doing.

{ config, lib, ... }:

let
  theme = config.my.theme.palettes.${config.my.theme.default};
  p = theme.palette;
  r = theme.roles;
in
{
  programs.tmux.extraConfig = lib.mkAfter ''
    ##### Colors -- ${theme.name} (my.theme) #####

    tm_surface="${r.surface}"
    tm_surface_alt="${r.surfaceAlt}"
    tm_muted="${r.muted}"
    tm_accent="${r.accent}"
    tm_accent_fg="${r.accentFg}"
    tm_attention="${p.yellow}"

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
    setw -g window-status-format " #I #W#{?#{||:#{window_bell_flag},#{window_zoomed_flag}}, ,}#{?window_bell_flag,!,}#{?window_zoomed_flag,Z,} "

    setw -g window-status-current-style "fg=$tm_accent_fg,bg=$tm_accent,bold"
    setw -g window-status-current-format " #I #W#{?#{||:#{window_bell_flag},#{window_zoomed_flag}}, ,}#{?window_bell_flag,!,}#{?window_zoomed_flag,Z,} "

    setw -g window-status-activity-style "fg=default,bg=default,underscore"
    setw -g window-status-bell-style "fg=$tm_attention,bg=default,blink,bold"

    set -g status-left-style "fg=$tm_surface,bg=$tm_attention,bold"
    set -g status-right-style "fg=$tm_muted,bg=$tm_surface"

    set -g clock-mode-colour "$tm_accent"
  '';
}
