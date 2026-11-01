# dwl-xkb-switch
#
# Steps to the next keyboard layout, as Super+Alt+K does; the bar's keyboard
# block runs it on a left click (pkgs/slstatus/config.h). dwl's switchxkblayout
# is only reachable from a bind, so this signals dwl (99-xkb-layout-signal):
# only the dwl this script was built with, as a dwl from before that patch
# would die of the SIGUSR1.

for pid in $(pgrep -x dwl); do
  [ "$(readlink "/proc/$pid/exe")" = "${DWL_BIN:?}" ] && kill -USR1 "$pid"
done
exit 0
