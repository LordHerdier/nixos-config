# hypr-session start|stop
#
# Replaces home-manager's hyprland.systemd hooks, which start/stop
# hyprland-session.target unconditionally. Its stop propagates to
# graphical-session.target, so a Hyprland next to another session (dwl on
# another VT) tore that session's user services down and overwrote its
# XDG_CURRENT_DESKTOP.
#
# Only the session that finds graphical-session.target down takes
# ownership, recorded in a marker file so only it stops the target.

marker="${XDG_RUNTIME_DIR:?}/hypr-session-owner"

case "${1:-}" in
start)
  if systemctl --user is-active --quiet graphical-session.target; then
    echo "hypr-session: graphical-session.target already active; leaving user services to the other session" >&2
    exit 0
  fi
  dbus-update-activation-environment --systemd \
    DISPLAY HYPRLAND_INSTANCE_SIGNATURE WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE
  echo "$HYPRLAND_INSTANCE_SIGNATURE" >"$marker"
  systemctl --user start hyprland-session.target
  ;;
stop)
  [ "$(cat "$marker" 2>/dev/null)" = "$HYPRLAND_INSTANCE_SIGNATURE" ] || exit 0
  rm -f "$marker"
  systemctl --user stop hyprland-session.target
  ;;
*)
  echo "usage: hypr-session start|stop" >&2
  exit 2
  ;;
esac
