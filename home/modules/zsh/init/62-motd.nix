# home/modules/zsh/init/62-motd.nix
#
# Once-a-day MOTD that works in long-lived tmux sessions.
# A precmd hook fires at the first prompt after any activity; if today's stamp
# file is missing, it asks whether to show the MOTD. The stamp is written
# *before* asking so concurrent shells/panes don't all prompt at once.

{ lib, pkgs, ... }:

{
  programs.zsh.initContent = lib.mkAfter ''
    motd() { ${pkgs.zsh}/bin/zsh ${../motd.sh}; }

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

      local reply
      read -k 1 "reply?Good morning! Show today's MOTD? [y/N/s=snooze 5m] "
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
