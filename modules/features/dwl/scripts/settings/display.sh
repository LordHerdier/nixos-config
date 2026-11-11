# Display page: mode and scale per output, backlight brightness, night light
# and power saver. Concatenated into dwl-settings by scripts.nix; relies on
# common.sh.
#
# Duplicating an output has no wlr-randr equivalent, so it runs wl-mirror
# fullscreen on the target output; it ends when the process is killed.
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

# name<TAB>WxH@Hz<TAB>scale<TAB>transform for every enabled output.
display_outputs() {
  wlr-randr --json | jq -r '
    .[] | select(.enabled) | . as $o
    | ($o.modes[] | select(.current)) as $m
    | [$o.name,
       "\($m.width)x\($m.height)@\(($m.refresh * 100 | round) / 100)",
       ($o.scale | tostring),
       ($o.transform // "normal")]
    | @tsv'
}

# Succeeds while a wl-mirror started by this page is running.
mirror_on() { pgrep -u "$(id -u)" -x wl-mirror >/dev/null; }

mirror_stop() { pkill -u "$(id -u)" -x wl-mirror || true; }

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

display_orientation_menu() {
  local out=$1 sel t label
  sel=$(
    for t in normal:'Normal' 90:'Rotated 90°' 180:'Upside down (180°)' \
      270:'Rotated 270°' flipped:'Flipped' flipped-90:'Flipped, 90°' \
      flipped-180:'Flipped, 180°' flipped-270:'Flipped, 270°'; do
      label=${t#*:}
      printf '%s\t%s\n' "$label" "${t%%:*}"
    done | pick "orientation $out"
  ) || return 0
  wlr-randr --output "$out" --transform "${sel#*$'\t'}" || pause
}

# Mirrors one output onto another, or stops mirroring.
display_duplicate_menu() {
  local src dst
  if mirror_on; then
    mirror_stop
    return 0
  fi
  if [ "$(display_outputs | wc -l)" -lt 2 ]; then
    notice 'duplicating needs at least two enabled outputs'
    return 0
  fi
  src=$(display_outputs | awk -F'\t' '{ printf "%s\t%s\n", $1, $1 }' \
    | pick 'duplicate from') || return 0
  src=${src#*$'\t'}
  dst=$(display_outputs | awk -F'\t' -v s="$src" \
    '$1 != s { printf "%s\t%s\n", $1, $1 }' | pick "show $src on") || return 0
  dst=${dst#*$'\t'}
  setsid -f wl-mirror --fullscreen-output "$dst" --fullscreen "$src" \
    >/dev/null 2>&1 || pause
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
          printf "Orient %-8s %s\torientation\t%s\n", $1, $4, $1
        }'
        if [ -n "$bri" ]; then
          printf 'Brightness  %s\tbrightness\n' "$bri"
        fi
        printf 'Duplicate  %s\tduplicate\n' "$(onoff mirror_on)"
        printf 'Night light  %s\tnightlight\n' "$(onoff nightlight_on)"
        printf 'Power saver  %s\tpowersave\n' "$(onoff powersave_on)"
      } | pick display
    ) || return 0
    IFS=$'\t' read -r _ kind out <<<"$sel"
    case $kind in
      mode) display_mode_menu "$out" ;;
      scale) display_scale_menu "$out" ;;
      orientation) display_orientation_menu "$out" ;;
      duplicate) display_duplicate_menu ;;
      brightness) display_brightness_menu ;;
      nightlight) dwl-nightlight ;;
      powersave) dwl-powersave ;;
      *) ;;
    esac
  done
}
