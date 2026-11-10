# home/modules/zsh/init/62-motd.nix
#
# Once-a-day MOTD that works in long-lived tmux sessions: a precmd hook
# asks at the first prompt of the day. A 30 s shared snooze is written
# *before* asking so other panes don't all prompt at once.

{ lib, pkgs, ... }:

{
  programs.zsh.initContent = lib.mkAfter ''
    motd() { MOTD_UPTIME=${../uptime.zsh} ${pkgs.zsh}/bin/zsh ${../motd.sh}; }

    zmodload zsh/datetime
    _motd_stamp="''${XDG_STATE_HOME:-$HOME/.local/state}/motd-last-shown"

    _motd_snooze="''${_motd_stamp}.snooze"
    _motd_snooze_secs=300

    _motd_daily() {
      # Cheap check: a couple of file reads and string/int compares
      local today=$(strftime %F)
      [[ -r $_motd_stamp && "$(<$_motd_stamp)" == "$today" ]] && return

      # Shared snooze (all panes): skip until the stored epoch has passed
      [[ -r $_motd_snooze ]] && (( EPOCHSECONDS < $(<$_motd_snooze) )) && return

      # Skip when not attached to a real terminal
      [[ -t 0 && -t 1 ]] || return

      mkdir -p "''${_motd_stamp:h}"
      # Short lock-style snooze so other panes don't ask while this prompt is open
      print -r -- $(( EPOCHSECONDS + 30 )) > "$_motd_snooze"

      local reply greeting hour=$(strftime %H)
      if (( 10#$hour < 12 )); then greeting="Good morning"
      elif (( 10#$hour < 18 )); then greeting="Good afternoon"
      else greeting="Good evening"
      fi
      read -k 1 "reply?$greeting! Show today's MOTD? [y/N/s=snooze 5m] "
      print
      case $reply in
        [yY])
          print -r -- "$today" > "$_motd_stamp"
          motd ;;
        [sS])
          print -r -- $(( EPOCHSECONDS + _motd_snooze_secs )) > "$_motd_snooze"
          print -P "%F{8}Snoozed for $(( _motd_snooze_secs / 60 )) minutes.%f" ;;
        *)
          print -r -- "$today" > "$_motd_stamp" ;;
      esac
    }

    autoload -Uz add-zsh-hook
    add-zsh-hook precmd _motd_daily
  '';
}
