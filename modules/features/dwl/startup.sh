# dwl-startup
#
# Runs inside the compositor (dwl -s), which exits when this does, so
# `sleep infinity` holds the session open until Super+Shift+L. Start
# long-running helpers above it with `&`. Built without errexit
# (default.nix): a failing step must not end the session.

# All of this user's sessions share one systemd user manager, so only the
# session that finds graphical-session.target down may touch it. Otherwise a
# second compositor (e.g. Hyprland on another VT) would overwrite
# XDG_CURRENT_DESKTOP, restart the portals under the wrong backend, and on
# exit stop the target (hypridle, easyeffects, portals) under the first.
if systemctl --user is-active --quiet graphical-session.target; then
  echo "dwl-startup: graphical-session.target already active; leaving user services to the other session" >&2
  owner=0
else
  owner=1
fi

if [ "$owner" = 1 ]; then
  # Hand the compositor's environment to user services and D-Bus
  # activated apps (portals, notification daemons, ...).
  systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
  dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

  # The user manager outlives a logout, so portals from a previous session
  # still carry its environment and route screencasts to its backend.
  # Stopped, D-Bus activation restarts them with the environment above,
  # which picks dwl-portals.conf. Done again on exit for the next session.
  stop_portals() {
    systemctl --user stop 'xdg-desktop-portal*.service' || true
  }
  stop_portals

  # Brings up graphical-session.target (hypridle, easyeffects), as
  # hyprland-session.target does under Hyprland. dwl SIGTERMs this script on
  # exit, and the trap stops the target again.
  trap 'dwl-caffeine --off; systemctl --user stop dwl-session.target; stop_portals' EXIT
  systemctl --user start dwl-session.target
else
  # Caffeine's idle inhibitor would otherwise keep the next session awake.
  trap 'dwl-caffeine --off' EXIT
fi
trap 'exit 0' TERM

dwl-wallpaper restore || true
# Not hyprpolkitagent, which Hyprland uses: its hyprtoolkit renderer
# aborts under dwl ("Couldn't open a gbm fd").
"$DWL_POLKIT_AGENT" &
# Notifications (Noctalia's job under Hyprland). mako is a runtime input,
# not on PATH, so its D-Bus activation file can't grab
# org.freedesktop.Notifications in a Hyprland session. Config: the active
# palette's (theme-set), else the built-in one.
mako_config=$DWL_MAKO_ACTIVE
[ -r "$mako_config" ] || mako_config=$DWL_MAKO_CONFIG
mako --config "$mako_config" &
# Clipboard history for dwl-clipboard (Super+V); runtime inputs like mako,
# as Noctalia keeps its own history under Hyprland. Both watchers exit with
# the compositor.
wl-paste --type text --watch cliphist store &
wl-paste --type image --watch cliphist store &

# Not exec: the shell has to outlive sleep for the trap to run.
sleep infinity &
wait
