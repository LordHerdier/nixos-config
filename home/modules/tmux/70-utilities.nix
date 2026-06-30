# home/modules/tmux/70-utilities.nix
{ lib, pkgs, ... }:
{
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

  home.file.".config/tmux/scripts/utility-popup.sh" = {
    executable = true;
    text = ''
      #!${pkgs.bash}/bin/bash
      WINDOW="$1"
      CMD="$2"
      SESSION="utilities"
      if ! tmux has-session -t "$SESSION" 2>/dev/null; then
        tmux new-session -d -s "$SESSION" -n spotify spotify_player
        tmux new-window  -t "$SESSION" -n concord concord
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

    # Kanagawa pink for the now-playing accent
    kanagawa_pink="#D27E99"

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
