# dwl-record [menu]
#
# Screen recording toggle (Super+Shift+R), standing in for Noctalia's
# screen_recorder plugin. With a recording running it stops it; otherwise it
# opens a popup (`menu`, below) to pick what to record. The video lands in
# ~/Videos/Recordings and a notification says where.
#
# The bind runs this through `spawnfocused` (97-spawn-focused.patch), so
# DWL_FOCUS_GEOM, the focused window's box, is still set here and reaches the
# popup before the popup takes focus.

dir="$HOME/Videos/Recordings"
state="${XDG_RUNTIME_DIR:-/tmp}/dwl-record.file"

recording() { pgrep -u "$(id -u)" -x wf-recorder >/dev/null; }

if [ "${1:-}" != menu ]; then
  if recording; then
    # SIGINT lets wf-recorder finish the file; killing it harder truncates it.
    pkill -INT -u "$(id -u)" -x wf-recorder
    while recording; do sleep 0.1; done
    file=$(cat "$state" 2>/dev/null || true)
    notify-send -a Recording "Recording saved" "Saved in <i>${file:-$dir}</i>."
    exit 0
  fi
  exec dwl-modal record 40 8 dwl-record menu
fi

# Everything is one of wf-recorder's -g geometries, except a single screen,
# which wf-recorder records by output name.
entries=(
  $'Window\twindow'
  $'Screen\tscreen'
  $'All screens\tall'
  $'Region\tregion'
)

sel=$(
  for i in "${!entries[@]}"; do
    printf '%d  %s\n' "$((i + 1))" "${entries[i]}"
  done | fzf \
    --delimiter '\t' --with-nth 1 \
    --layout reverse --no-sort --prompt 'record> ' \
    --header '1-4 or enter: pick · esc: close' \
    --bind '1:pos(1)+accept,2:pos(2)+accept,3:pos(3)+accept,4:pos(4)+accept'
) || exit 0
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

mkdir -p "$dir"
file="$dir/$(date +'%Y-%m-%d-%H%M%S')_recording.mp4"
printf '%s\n' "$file" >"$state"

# Detached, for the reason given at the end of dwl-clipboard: the popup only
# closes once nothing holds its pty, and the recording must outlive it.
setsid -f wf-recorder "${args[@]}" -f "$file" >/dev/null 2>&1
notify-send -a Recording "Recording started" "Press Super+Shift+R to stop."
