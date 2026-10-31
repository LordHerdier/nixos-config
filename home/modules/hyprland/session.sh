# hypr-session start|stop
#
# Replaces home-manager's wayland.windowManager.hyprland.systemd hooks, which
# stop and start hyprland-session.target unconditionally. That target
# propagates its stop to graphical-session.target, so a Hyprland launched
# next to another session (dwl on a different VT) tore the other session's
# user services down, and overwrote the XDG_CURRENT_DESKTOP it had imported.
#
# Only the session that finds graphical-session.target down takes ownership,
# and records itself in a marker file so only it stops the target on exit.

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
