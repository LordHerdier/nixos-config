# dwl-startup
#
# Runs inside the compositor (dwl -s). dwl exits when this process does,
# so it must stay alive: `sleep infinity` holds the session open until
# Super+Shift+L. Add long-running helpers (bar, wallpaper, polkit agent)
# above it with `&`.
#
# Built without errexit (default.nix): a step that fails here must not end
# the session.

# Every session of this user shares one systemd user manager, so only
# the session that finds graphical-session.target down may touch it.
# A second compositor (e.g. Hyprland already running on another VT)
# would otherwise overwrite XDG_CURRENT_DESKTOP, restart the portals
# under the wrong backend, and on exit stop the target out from under
# the first session (hypridle, easyeffects, portals).
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

  # The user manager outlives a logout, so portals started by a previous
  # session (e.g. Hyprland) are still running with its WAYLAND_DISPLAY
  # and XDG_CURRENT_DESKTOP, routing screencasts to that session's
  # backend. Stopping them lets D-Bus activation restart them on first
  # use with the environment imported above, which picks
  # dwl-portals.conf. Done again on exit for whichever session is next.
  stop_portals() {
    systemctl --user stop 'xdg-desktop-portal*.service' || true
  }
  stop_portals

  # Brings up graphical-session.target (hypridle, easyeffects), as
  # hyprland-session.target does under Hyprland. dwl SIGTERMs this
  # script on exit, which the trap turns into stopping the target again.
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
# Notifications, which Noctalia owns under Hyprland. mako is a runtime
# input of this script rather than on PATH, so its D-Bus activation file
# can't grab org.freedesktop.Notifications in a Hyprland session.
mako --config "$DWL_MAKO_CONFIG" &
# Clipboard history for dwl-clipboard (Super+V). Runtime inputs rather
# than PATH, like mako: Noctalia keeps its own history under Hyprland.
# Both exit with the compositor when the Wayland connection drops.
wl-paste --type text --watch cliphist store &
wl-paste --type image --watch cliphist store &
# The setcap wrapper (modules/features/librepods.nix), not the store
# binary: it needs cap_net_admin. --hide starts it tray-only, which
# shows up in the bar's systray.
/run/wrappers/bin/librepods --hide &

# Not exec: the shell has to outlive sleep for the trap to run.
sleep infinity &
wait
