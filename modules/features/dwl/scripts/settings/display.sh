# Display page: mode and scale per output, backlight brightness, night light
# and power saver. Concatenated into dwl-settings by scripts.nix; relies on
# common.sh.
#
# TODO: runtime-only. wlr-randr changes are lost when dwl restarts or an
# output is replugged, falling back to config.h's monrules. To persist them,
# write a state file dwl-startup re-applies, or generate monrules from Nix.

nightlight_on() { pgrep -u "$(id -u)" -x wlsunset >/dev/null; }

# dwl-powersave keeps what to restore here while it is on.
powersave_on() { [ -e "${XDG_RUNTIME_DIR:?}/dwl-powersave" ]; }

# The backlight as "85%"; nothing when there is no backlight.
backlight_pct() {
  brightnessctl -m -c backlight 2>/dev/null | awk -F, 'NR == 1 { print $4 }'
}

# name<TAB>WxH@Hz<TAB>scale for every enabled output.
display_outputs() {
  wlr-randr --json | jq -r '
    .[] | select(.enabled) | . as $o
    | ($o.modes[] | select(.current)) as $m
    | [$o.name,
       "\($m.width)x\($m.height)@\(($m.refresh * 100 | round) / 100)",
       ($o.scale | tostring)]
    | @tsv'
}

display_summary() {
  local out bri extra=''
  out=$(display_outputs | awk -F'\t' '
    NR == 1 { printf "%s %s", $1, $2 }
    END { if (NR > 1) printf " +%d", NR - 1 }' || true)
  bri=$(backlight_pct || true)
  if nightlight_on; then extra=' · night light'; fi
  echo "${out:-no outputs}${bri:+ · $bri}$extra"
}

display_mode_menu() {
  local out=$1 sel
  sel=$(
    wlr-randr --json | jq -r --arg o "$out" '
      .[] | select(.name == $o) | .modes[]
      | [(if .current then "*" else " " end)
         + " \(.width)x\(.height) @ \((.refresh * 100 | round) / 100) Hz"
         + (if .preferred then " (preferred)" else "" end),
         "\(.width)x\(.height)@\(.refresh)"]
      | @tsv' | pick "mode $out"
  ) || return 0
  wlr-randr --output "$out" --mode "${sel#*$'\t'}" || pause
}

display_scale_menu() {
  local out=$1 sel s
  sel=$(
    for s in 1 1.25 1.5 1.75 2; do
      printf '%s\t%s\n' "$s" "$s"
    done | pick "scale $out"
  ) || return 0
  wlr-randr --output "$out" --scale "${sel#*$'\t'}" || pause
}

display_brightness_menu() {
  local sel p
  sel=$(
    for p in 5 10 20 30 40 50 60 70 80 90 100; do
      printf '%s%%\t%s\n' "$p" "$p"
    done | pick brightness
  ) || return 0
  brightnessctl -q -c backlight set "${sel#*$'\t'}%" || pause
  dwl-bar-refresh
}

display_menu() {
  local sel kind out bri
  while :; do
    bri=$(backlight_pct || true)
    sel=$(
      {
        display_outputs | awk -F'\t' '{
          printf "Mode   %-8s %s\tmode\t%s\n", $1, $2, $1
          printf "Scale  %-8s %s\tscale\t%s\n", $1, $3, $1
        }'
        if [ -n "$bri" ]; then
          printf 'Brightness  %s\tbrightness\n' "$bri"
        fi
        printf 'Night light  %s\tnightlight\n' "$(onoff nightlight_on)"
        printf 'Power saver  %s\tpowersave\n' "$(onoff powersave_on)"
      } | pick display
    ) || return 0
    IFS=$'\t' read -r _ kind out <<<"$sel"
    case $kind in
      mode) display_mode_menu "$out" ;;
      scale) display_scale_menu "$out" ;;
      brightness) display_brightness_menu ;;
      nightlight) dwl-nightlight ;;
      powersave) dwl-powersave ;;
      *) ;;
    esac
  done
}
