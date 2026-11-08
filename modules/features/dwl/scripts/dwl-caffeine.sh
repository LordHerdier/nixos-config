# dwl-caffeine [--off]
#
# Toggles keeping the screen awake (Super+Shift+I), standing in for
# Noctalia's caffeine-toggle. Holds a systemd idle inhibitor, which hypridle
# honours, rather than stopping hypridle, so locking before suspend still
# works. The bar shows a cup while it's on. dwl-startup runs --off on exit
# so the inhibitor doesn't outlive the session.

# systemd-inhibit stays up as long as its child; killing the child releases
# the inhibitor without leaving the sleep behind.
if pid=$(pgrep -u "$(id -u)" -o -f -- '--who=dwl-caffeine'); then
  pkill -P "$pid" || true
  [ "${1:-}" = --off ] && exit 0
  notify-send -a Caffeine "Caffeine off"
elif [ "${1:-}" = --off ]; then
  exit 0
else
  setsid -f systemd-inhibit --what=idle --who=dwl-caffeine --why="Caffeine (Super+Shift+I)" \
    sleep infinity >/dev/null 2>&1
  notify-send -a Caffeine "Caffeine on"
fi
dwl-bar-refresh
