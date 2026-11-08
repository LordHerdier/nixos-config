# dwl-screenshot
#
# Region screenshot (Super+Shift+S), standing in for `hyprshot -z --mode
# region`, which calls hyprctl and so fails outside Hyprland. Same result:
# frozen screen while you drag, PNG in ~/Pictures/Screenshots under
# hyprshot's naming, copied to the clipboard, notification. Esc cancels.

dir="$HOME/Pictures/Screenshots"
file="$dir/$(date +'%Y-%m-%d-%H%M%S')_screenshot.png"

# hyprpicker -r -z draws a frozen copy of the screen over everything, the way
# hyprshot's -z does; it only needs layer-shell and screencopy, both in dwl.
hyprpicker -r -z &
freeze=$!
trap 'kill "$freeze" 2>/dev/null || true' EXIT
sleep 0.2

geometry=$(slurp -d) || exit 0
kill "$freeze" 2>/dev/null || true
# Let the freeze layer unmap so it isn't in the capture.
sleep 0.05

mkdir -p "$dir"
grim -g "$geometry" "$file"
wl-copy --type image/png <"$file"
notify-send -i "$file" -a Screenshot "Screenshot saved" \
  "Saved in <i>$file</i> and copied to the clipboard."
