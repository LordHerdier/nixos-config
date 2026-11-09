# Sound page: default output and input, their volume and mute, the full mixer
# and the AirPods noise control. Concatenated into dwl-settings by scripts.nix;
# relies on common.sh.
#
# wpctl has no machine-readable listing, so audio_nodes reads `wpctl status`.

airpods_status=${XDG_STATE_HOME:-$HOME/.local/state}/librepods/status.json

# One line per node in the Audio section's Sinks or Sources list:
# id<TAB>default mark ('*' or ' ')<TAB>volume %<TAB>muted (1/0)<TAB>name
audio_nodes() {
  wpctl status | awk -v want="$1" '
    /^Audio/ { audio = 1; next }
    /^[A-Za-z]/ { audio = 0 }
    audio && /(├|└)─ / {
      sect = $0
      sub(/.*─ /, "", sect)
      sub(/:.*/, "", sect)
      next
    }
    audio && sect == want && match($0, /[0-9]+\. /) {
      mark = ($0 ~ /\*[ ]+[0-9]+\. /) ? "*" : " "
      id = substr($0, RSTART, RLENGTH - 2)
      rest = substr($0, RSTART + RLENGTH)
      pct = ""; muted = 0
      if (match(rest, / \[vol: [0-9.]+( MUTED)?\]$/)) {
        v = substr(rest, RSTART, RLENGTH)
        rest = substr(rest, 1, RSTART - 1)
        muted = (v ~ /MUTED/) ? 1 : 0
        gsub(/[^0-9.]/, "", v)
        pct = int(v * 100 + 0.5)
      }
      printf "%s\t%s\t%s\t%s\t%s\n", id, mark, pct, muted, rest
    }'
}

# "60%" or "60% muted" for the default node of a kind, empty when none.
audio_default() {
  audio_nodes "$1" | awk -F'\t' '
    $2 == "*" { printf "%s%%%s", $3, ($4 == 1 ? " muted" : "") }'
}

sound_summary() {
  local out inp
  out=$(audio_default Sinks || true)
  inp=$(audio_default Sources || true)
  echo "out ${out:-none} · in ${inp:-none}"
}

sound_volume() {
  local sel v
  sel=$(
    for v in 0 10 20 30 40 50 60 70 80 90 100; do
      printf '%s%%\t%s\n' "$v" "$v"
    done | pick volume
  ) || return 0
  wpctl set-volume "$1" "${sel#*$'\t'}%"
}

# Sinks or Sources: pick the default device, set its volume, toggle its mute.
sound_device_menu() {
  local kind=$1 label target sel what id
  if [ "$kind" = Sinks ]; then
    label=output target=@DEFAULT_AUDIO_SINK@
  else
    label=input target=@DEFAULT_AUDIO_SOURCE@
  fi
  while :; do
    sel=$(
      {
        audio_nodes "$kind" | awk -F'\t' '
          { printf "%s %-56s %3s%%%s\tdev\t%s\n", $2, $5, $3, ($4 == 1 ? " muted" : ""), $1 }'
        printf 'Volume…\tvolume\n'
        printf 'Toggle mute\tmute\n'
      } | pick "$label"
    ) || return 0
    IFS=$'\t' read -r _ what id <<<"$sel"
    case $what in
      dev) wpctl set-default "$id" ;;
      volume) sound_volume "$target" ;;
      mute) wpctl set-mute "$target" toggle ;;
      *) ;;
    esac
    dwl-bar-refresh
  done
}

sound_menu() {
  local sel
  while :; do
    sel=$(
      {
        printf 'Output  %s\tout\n' "$(audio_default Sinks)"
        printf 'Input   %s\tin\n' "$(audio_default Sources)"
        printf 'Open the mixer\tmixer\n'
        if [ -s "$airpods_status" ]; then
          printf 'AirPods noise control\tairpods\n'
        fi
      } | pick sound
    ) || return 0
    case ${sel#*$'\t'} in
      out) sound_device_menu Sinks ;;
      in) sound_device_menu Sources ;;
      mixer) dwl-modal mixer; exit 0 ;;
      airpods) dwl-airpods || true ;;
      *) ;;
    esac
  done
}
