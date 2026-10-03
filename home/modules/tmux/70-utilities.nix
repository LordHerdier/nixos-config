# home/modules/tmux/70-utilities.nix
{
  config,
  lib,
  pkgs,
  ...
}:

let
  theme = config.my.theme.active;
  p = theme.palette;
  r = theme.roles;

  # fzf takes one flat --color argument. Spelled out rather than built
  # with a helper because the mapping from fzf's slot names to our roles
  # is the interesting part.
  fzfColors = lib.concatStringsSep "," [
    "bg:${r.surface}"
    "bg+:${r.surfaceAlt}"
    "fg:${r.muted}"
    "fg+:${p.fg}"
    "hl:${r.accent}"
    "hl+:${r.accent}"
    "prompt:${p.yellow}"
    "pointer:${p.magenta}"
    "marker:${r.success}"
    "border:${r.surfaceAlt}"
    "info:${r.muted}"
  ];
in
{
  home.file.".config/tmux/scripts/session-picker.sh" = {
    executable = true;
    text = ''
      #!${pkgs.bash}/bin/bash

      CURRENT=$(tmux display-message -p '#{session_name}' 2>/dev/null || echo "")

      SESSION=$(tmux list-sessions -F '#{session_name}|#{session_windows}|#{session_attached}' 2>/dev/null \
        | while IFS='|' read -r name windows attached; do
            [ "$name" = "$CURRENT" ] && marker="●" || marker="○"
            [ "$attached" -gt 0 ] && here=" (here)" || here=""
            printf '%s|%s %s  %s win%s\n' "$name" "$marker" "$name" "$windows" "$here"
          done \
        | ${pkgs.fzf}/bin/fzf \
            --no-sort \
            --delimiter='|' \
            --with-nth=2 \
            --prompt="  sessions  " \
            --bind='e:down,u:up,ctrl-e:preview-down,ctrl-u:preview-up' \
            --preview='tmux list-windows -t {1} -F "  #{window_index}  #{window_name}#{?window_active,  ←,}" 2>/dev/null' \
            --preview-window='right:40%:border-left' \
            --height=100% \
            --color='${fzfColors}' \
        | cut -d'|' -f1)

      [ -z "$SESSION" ] && exit 0
      tmux switch-client -t "$SESSION"
    '';
  };

  home.file.".config/tmux/scripts/now-playing.sh" = {
    executable = true;
    text = ''
      #!${pkgs.bash}/bin/bash
      PLAYER="spotify_player,spotify"
      MAX_LEN=30
      status=$(${pkgs.playerctl}/bin/playerctl --player="$PLAYER" status 2>/dev/null)
      case "$status" in
        Playing) icon="♪" ;;
        Paused)  icon="⏸" ;;
        *) exit 0 ;;
      esac
      meta=$(${pkgs.playerctl}/bin/playerctl --player="$PLAYER" \
        metadata --format '{{ title }} - {{ artist }}' 2>/dev/null)
      [ -z "$meta" ] && exit 0
      if [ ''${#meta} -gt $MAX_LEN ]; then
        meta="''${meta:0:$((MAX_LEN - 1))}…"
      fi
      printf '%s %s' "$icon" "$meta"
    '';
  };

  home.file.".config/tmux/scripts/new-session-popup.sh" = {
    executable = true;
    text = ''
      #!${pkgs.bash}/bin/bash
      read -rp "Session name: " name
      [ -z "$name" ] && exit 0
      tmux new-session -d -s "$name" && tmux switch-client -t "$name"
    '';
  };

  home.file.".config/tmux/scripts/utility-popup.sh" = {
    executable = true;
    text = ''
      #!${pkgs.bash}/bin/bash
      WINDOW="$1"
      CMD="$2"
      SESSION="utils"
      if ! tmux has-session -t "$SESSION" 2>/dev/null; then
        tmux new-session -d -s "$SESSION" -n spotify spotify_player
        tmux new-window  -t "$SESSION" -n concord concord
        tmux new-window  -t "$SESSION" -n rsync   lazyrsync
      fi
      if ! tmux list-windows -t "$SESSION" -F '#W' | grep -qx "$WINDOW"; then
        tmux new-window -t "$SESSION" -n "$WINDOW" "$CMD"
      fi
      tmux select-window -t "$SESSION:$WINDOW"
      exec tmux attach -t "$SESSION"
    '';
  };

  programs.tmux.extraConfig = lib.mkAfter ''
    ##### Utility popups + spotify mouse controls #####

    # Transport controls (work from anywhere)
    bind-key -r Space run-shell "playerctl --player=spotify_player,spotify play-pause"
    bind-key -r M-n   run-shell "playerctl --player=spotify_player,spotify next"
    bind-key -r M-b   run-shell "playerctl --player=spotify_player,spotify previous"
    bind-key -r M-=   run-shell "playerctl --player=spotify_player,spotify volume 0.05+"
    bind-key -r M--   run-shell "playerctl --player=spotify_player,spotify volume 0.05-"
    bind-key -r M-l   run-shell "spotify_player like" \; display-message "♥ liked"

    # Popup launchers
    bind-key M-s display-popup -E -w 90% -h 90% \
      "~/.config/tmux/scripts/utility-popup.sh spotify spotify_player"
    bind-key M-d display-popup -E -w 90% -h 90% \
      "~/.config/tmux/scripts/utility-popup.sh concord concord"
    bind-key M-r display-popup -E -w 90% -h 90% \
      "~/.config/tmux/scripts/utility-popup.sh rsync lazyrsync"
    bind-key M-g display-popup -E -w 90% -h 90% -d '#{pane_current_path}' lazygit
    bind-key M-c display-popup -E -w 90% -h 90% -d '#{pane_current_path}' claude
    bind-key S display-popup -E "~/.config/tmux/scripts/new-session-popup.sh"

    ##### Mouse bindings for the now-playing segment #####

    # Left click   → play/pause
    bind-key -T root MouseDown1StatusRight {
      if-shell -F '#{m:*nowplaying*,#{mouse_status_range}}' \
        'run-shell "playerctl --player=spotify_player,spotify play-pause"'
    }

    # Middle click → next track
    bind-key -T root MouseDown2StatusRight {
      if-shell -F '#{m:*nowplaying*,#{mouse_status_range}}' \
        'run-shell "playerctl --player=spotify_player,spotify next"'
    }

    # Scroll up    → volume up
    bind-key -T root WheelUpStatusRight {
      if-shell -F '#{m:*nowplaying*,#{mouse_status_range}}' \
        'run-shell "playerctl --player=spotify_player,spotify volume 0.05+"'
    }

    # Scroll down  → volume down
    bind-key -T root WheelDownStatusRight {
      if-shell -F '#{m:*nowplaying*,#{mouse_status_range}}' \
        'run-shell "playerctl --player=spotify_player,spotify volume 0.05-"'
    }
  '';
}
