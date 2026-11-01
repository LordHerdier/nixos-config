# dwl-modal TITLE COLS ROWS CMD [ARGS...]
#
# Toggles a control popup: a kitty with app_id "modal", which the "modal" rule
# in pkgs/dwl/config.h floats and centres, COLS x ROWS cells big and running
# CMD. If a modal with this TITLE is already open it is closed instead, so the
# bind that opens it also dismisses it.
#
# The running kitty is found by its command line, which still holds the
# arguments it was started with below; the trailing " -o" keeps one title from
# matching another that starts with it. Titles are used as a regex, so keep
# them to plain words.

title=$1
cols=$2
rows=$3
shift 3

if pkill -u "$(id -u)" -f -- "--class modal --title $title -o"; then
  exit 0
fi

exec kitty --class modal --title "$title" \
  -o remember_window_size=no \
  -o initial_window_width="${cols}c" \
  -o initial_window_height="${rows}c" \
  "$@"
