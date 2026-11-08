# dwl-bar-refresh
#
# Redraws the bar's status text now rather than at slstatus's next 5 s tick.
# Everything that changes what a status block shows runs this: the volume,
# brightness and keyboard layout binds in pkgs/dwl/config.h, the bar's own
# click regions in pkgs/slstatus/config.h, and dwl-dnd, dwl-caffeine,
# dwl-nightlight and dwl-settings.

pkill -USR1 -x slstatus || true
