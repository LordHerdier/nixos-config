# dwl-xkb-switch
#
# Steps to the next keyboard layout, as Super+Alt+K does, for the bar's
# keyboard block and dwl-settings (which first writes dwl-xkb-set). dwl's
# switchxkblayout is only reachable from a bind, so this sends SIGUSR1
# (99-xkb-layout-signal) -- only to the dwl it was built with, as one from
# before that patch would die of it.

for pid in $(pgrep -x dwl); do
  [ "$(readlink "/proc/$pid/exe")" = "${DWL_BIN:?}" ] && kill -USR1 "$pid"
done
exit 0
