# home/modules/tmux/30-colors-kanagawa.nix

{ lib, ... }:

{
  programs.tmux.extraConfig = lib.mkAfter ''
    ##### Kanagawa Color Scheme #####

    kanagawa_dark_gray="#16161D"
    kanagawa_gray="#2A2A37"
    kanagawa_light_gray="#727169"
    kanagawa_light_blue="#7fb4ca"
    kanagawa_yellow="#e6c384"
    kanagawa_white="#dcd7ba"
    kanagawa_pink="#D27E99"
    kanagawa_green="#98bb6c"
    kanagawa_red="#C34043"

    set -g window-style "fg=default,bg=default"
    set -g window-active-style "fg=default,bg=default"

    set -g pane-border-style "fg=$kanagawa_gray"
    set -g pane-active-border-style "fg=$kanagawa_light_blue"
    set -g pane-border-lines "single"

    set -g display-panes-colour "$kanagawa_light_blue"
    set -g display-panes-active-colour "$kanagawa_light_blue"

    set -g status-style "fg=$kanagawa_light_gray,bg=$kanagawa_dark_gray"

    set -g message-style "fg=$kanagawa_dark_gray,bg=$kanagawa_yellow,bold"
    set -g message-command-style "fg=$kanagawa_yellow,bg=$kanagawa_dark_gray,bold"
    set -g mode-style "fg=$kanagawa_dark_gray,bg=$kanagawa_yellow,bold"

    setw -g window-status-style "fg=$kanagawa_light_gray,bg=$kanagawa_dark_gray"
    setw -g window-status-format " #I #W#{?#{||:#{window_bell_flag},#{window_zoomed_flag}}, ,}#{?window_bell_flag,!,}#{?window_zoomed_flag,Z,} "

    setw -g window-status-current-style "fg=$kanagawa_dark_gray,bg=$kanagawa_light_blue,bold"
    setw -g window-status-current-format " #I #W#{?#{||:#{window_bell_flag},#{window_zoomed_flag}}, ,}#{?window_bell_flag,!,}#{?window_zoomed_flag,Z,} "

    setw -g window-status-activity-style "fg=default,bg=default,underscore"
    setw -g window-status-bell-style "fg=$kanagawa_yellow,bg=default,blink,bold"

    set -g status-left-style "fg=$kanagawa_dark_gray,bg=$kanagawa_yellow,bold"
    set -g status-right-style "fg=$kanagawa_light_gray,bg=$kanagawa_dark_gray"

    set -g clock-mode-colour "$kanagawa_light_blue"
  '';
}

