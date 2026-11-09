# slstatus-notifications
#
# Nerd Font bell, crossed out while mako's do-not-disturb mode is on
# (dwl-dnd), after a coffee cup while dwl-caffeine's idle inhibitor runs.
# Nerd Font icons draw past their one-cell advance (the bell to about 1.4
# cells, the crossed-out one nearly 2), and dwl's bar clips each block to
# its advance, so the trailing spaces give them room.

if pgrep -u "$(id -u)" -f -- '--who=dwl-caffeine' >/dev/null; then
  printf '^fg(%s) ^fg()' "$SLSTATUS_ACCENT"
fi
# Not `makoctl mode | grep -q`: grep quitting early can SIGPIPE makoctl,
# which pipefail would read as DnD being off.
if grep -qx do-not-disturb <<<"$(makoctl mode)"; then
  printf '^fg(%s) ^fg()\n' "$SLSTATUS_ALERT"
else
  printf '^fg(%s) ^fg()\n' "$SLSTATUS_ACCENT"
fi
