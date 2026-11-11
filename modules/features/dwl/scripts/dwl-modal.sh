# dwl-modal NAME
#
# Toggles a control popup: a kitty with app_id "modal", which config.h's
# "modal" rule floats and centres. NAME picks its size (cells) and command
# from the table below, shared by config.h's MODAL() binds and the bar's
# click regions. If that popup is already open it is closed instead.
#
# The open popup is found by its command line; the trailing " -o" stops one
# name matching another that starts with it. Names are used as a regex, so
# keep them to plain words.

name=${1:-}

case $name in
  # name             cols rows  command
  binds)         set -- 100 30 dwl-binds ;;
  calendar)      set -- 66 11 dwl-calendar ;;
  clipboard)     set -- 120 30 dwl-clipboard ;;
  emoji)         set -- 80 24 dwl-emoji ;;
  mixer)         set -- 110 30 wiremix ;;
  network)       set -- 90 24 dwl-settings network ;;
  notifications) set -- 120 30 dwl-notifications ;;
  record)        set -- 72 8 dwl-record menu ;;
  session)       set -- 60 12 dwl-session-menu ;;
  settings)      set -- 90 28 dwl-settings ;;
  wallpaper)     set -- 140 35 dwl-wallpaper-pick ;;
  windows)       set -- 100 20 dwl-windows ;;
  *)
    echo "dwl-modal: unknown popup '$name'" >&2
    exit 2
    ;;
esac
cols=$1
rows=$2
shift 2

if pkill -u "$(id -u)" -f -- "--class modal --title $name -o"; then
  exit 0
fi

exec kitty --class modal --title "$name" \
  -o remember_window_size=no \
  -o initial_window_width="${cols}c" \
  -o initial_window_height="${rows}c" \
  "$@"
