# dwl-record [menu]
#
# Screen recording toggle (Super+Shift+R), standing in for Noctalia's
# screen_recorder plugin. With a recording running it stops it; otherwise it
# opens a popup (`menu`, below) to pick what to record. The video lands in
# ~/Videos/Recordings and a notification says where.
#
# The popup also toggles audio: s records system audio (the default sink's
# monitor), m the default microphone. The choice is remembered. wf-recorder
# takes one audio device, so with both on they are mixed through a temporary
# null sink, which stopping unloads again.
#
# The bind runs this through `spawnfocused` (97-spawn-focused.patch), so
# DWL_FOCUS_GEOM, the focused window's box, is still set here and reaches the
# popup before the popup takes focus.

dir="$HOME/Videos/Recordings"
state="${XDG_RUNTIME_DIR:-/tmp}/dwl-record.file"
modules="${XDG_RUNTIME_DIR:-/tmp}/dwl-record.modules"
prefs="${XDG_STATE_HOME:-$HOME/.local/state}/dwl-record.audio"

recording() { pgrep -u "$(id -u)" -x wf-recorder >/dev/null; }

# Unload the mix's null sink and loopbacks, if a recording left them behind.
unload_mix() {
  [ -f "$modules" ] || return 0
  while read -r id; do
    pactl unload-module "$id" || true
  done <"$modules"
  rm -f "$modules"
}

if [ "${1:-}" != menu ]; then
  if recording; then
    # SIGINT lets wf-recorder finish the file; killing it harder truncates it.
    pkill -INT -u "$(id -u)" -x wf-recorder
    while recording; do sleep 0.1; done
    unload_mix
    file=$(cat "$state" 2>/dev/null || true)
    notify-send -a Recording "Recording saved" "Saved in <i>${file:-$dir}</i>."
    exit 0
  fi
  exec dwl-modal record 72 8 dwl-record menu
fi

# Everything is one of wf-recorder's -g geometries, except a single screen,
# which wf-recorder records by output name.
entries=(
  $'Window\twindow'
  $'Screen\tscreen'
  $'All screens\tall'
  $'Region\tregion'
)

system=0 mic=0
# shellcheck source=/dev/null
[ -f "$prefs" ] && . "$prefs"

# s and m flip the audio toggles and redraw; anything else is a pick.
while :; do
  mark() { [ "$1" = 1 ] && echo x || echo ' '; }
  out=$(
    for i in "${!entries[@]}"; do
      printf '%d  %s\n' "$((i + 1))" "${entries[i]}"
    done | fzf \
      --delimiter '\t' --with-nth 1 \
      --layout reverse --no-sort --prompt 'record> ' \
      --header "1-4 or enter: pick · s [$(mark "$system")] system audio · m [$(mark "$mic")] mic · esc: close" \
      --expect s,m \
      --bind '1:pos(1)+accept,2:pos(2)+accept,3:pos(3)+accept,4:pos(4)+accept'
  ) || exit 0
  key=$(head -n1 <<<"$out")
  case $key in
  s) system=$((1 - system)) ;;
  m) mic=$((1 - mic)) ;;
  *) break ;;
  esac
  mkdir -p "$(dirname "$prefs")"
  printf 'system=%s\nmic=%s\n' "$system" "$mic" >"$prefs"
done
sel=$(tail -n1 <<<"$out")
mode=${sel#*$'\t'}

args=()
case $mode in
window)
  [ -n "${DWL_FOCUS_GEOM:-}" ] || {
    notify-send -a Recording "No window to record"
    exit 0
  }
  args=(-g "$DWL_FOCUS_GEOM")
  ;;
screen)
  output=$(slurp -o -f '%o') || exit 0
  args=(-o "$output")
  ;;
all)
  # Bounding box of every enabled output, in the logical (scaled, rotated)
  # coordinates slurp and wf-recorder use.
  geometry=$(
    wlr-randr --json | jq -r '
      [.[] | select(.enabled) | . as $o
        | ($o.modes[] | select(.current)) as $m
        | ($o.transform | test("90|270")) as $swap
        | { x: $o.position.x, y: $o.position.y,
            w: ((if $swap then $m.height else $m.width end) / $o.scale | round),
            h: ((if $swap then $m.width else $m.height end) / $o.scale | round) }]
      | (map(.x) | min) as $x0 | (map(.y) | min) as $y0
      | "\($x0),\($y0) \((map(.x + .w) | max) - $x0)x\((map(.y + .h) | max) - $y0)"'
  )
  args=(-g "$geometry")
  ;;
region)
  geometry=$(slurp -d) || exit 0
  args=(-g "$geometry")
  ;;
esac

# --audio takes a PulseAudio source: one directly, or both mixed.
audio=()
if [ "$system" = 1 ] || [ "$mic" = 1 ]; then
  unload_mix
  sys_src="$(pactl get-default-sink).monitor"
  mic_src=$(pactl get-default-source)
  if [ "$system" = 1 ] && [ "$mic" = 1 ]; then
    {
      pactl load-module module-null-sink sink_name=dwl-record \
        sink_properties=device.description=dwl-record
      pactl load-module module-loopback source="$sys_src" sink=dwl-record
      pactl load-module module-loopback source="$mic_src" sink=dwl-record
    } >"$modules"
    audio=(--audio=dwl-record.monitor)
  elif [ "$system" = 1 ]; then
    audio=("--audio=$sys_src")
  else
    audio=("--audio=$mic_src")
  fi
fi

mkdir -p "$dir"
file="$dir/$(date +'%Y-%m-%d-%H%M%S')_recording.mp4"
printf '%s\n' "$file" >"$state"

# Detached, for the reason given at the end of dwl-clipboard: the popup only
# closes once nothing holds its pty, and the recording must outlive it. stdin
# is the pty here, unlike there, so it needs redirecting too.
setsid -f wf-recorder "${args[@]}" "${audio[@]}" -f "$file" </dev/null >/dev/null 2>&1
notify-send -a Recording "Recording started" "Press Super+Shift+R to stop."
