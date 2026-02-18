# home/modules/zsh/profile.nix

{ ... }:

{
  programs.zsh.profileExtra = ''
    [[ -z $PS1 ]] && return

    # Daily MOTD: run ~/bin/wut once per day
    local wut_cmd="$HOME/bin/wut"
    local stamp_file="$HOME/.last_wut_date"
    local today=$(date +%F)

    if [[ -x $wut_cmd ]]; then
      if [[ ! -f $stamp_file ]] || [[ $(<"$stamp_file") != $today ]]; then
        "$wut_cmd"
        print -r -- $today >| "$stamp_file"
      fi
    fi

    export GPG_TTY=$(tty)
  '';
}

