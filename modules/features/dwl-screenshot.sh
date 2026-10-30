# dwl-screenshot
#
# Region screenshot, standing in for `hyprshot -z --mode region` (which calls
# hyprctl to clamp the selection, so it fails outside Hyprland). Same result:
# the screen freezes while you drag, the PNG lands in ~/Pictures/Screenshots
# under hyprshot's naming, is copied to the clipboard, and a notification
# shows it. Esc in slurp cancels without saving.

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
