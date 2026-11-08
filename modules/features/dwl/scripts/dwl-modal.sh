# dwl-modal NAME
#
# Toggles a control popup: an st-wl with app_id "modal", which the "modal" rule
# in pkgs/dwl/config.h floats and centres. NAME picks the popup's size (in
# cells) and command from the table below, the one place either is set, so
# config.h's MODAL() binds and the bar's click regions (pkgs/slstatus/config.h)
# always open the same thing. If that popup is already open it is closed
# instead, so the bind that opens it also dismisses it.
#
# The running st-wl is found by its command line, which still holds the
# arguments it was started with below; the trailing " -g" keeps one title from
# matching another that starts with it. Names are used as a regex, so keep
# them to plain words.

name=${1:-}

case $name in
  # name             cols rows  command
  binds)         set -- 100 30 dwl-binds ;;
  calendar)      set -- 66 11 dwl-calendar ;;
  clipboard)     set -- 120 30 dwl-clipboard ;;
  emoji)         set -- 80 24 dwl-emoji ;;
  mixer)         set -- 110 30 wiremix ;;
  network)       set -- 90 24 dwl-network ;;
  notifications) set -- 120 30 dwl-notifications ;;
  record)        set -- 72 8 dwl-record menu ;;
  session)       set -- 60 12 dwl-session-menu ;;
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

if pkill -u "$(id -u)" -f -- "-c modal -T $name -g"; then
  exit 0
fi

exec st-wl -c modal -T "$name" -g "${cols}x${rows}" "$@"
