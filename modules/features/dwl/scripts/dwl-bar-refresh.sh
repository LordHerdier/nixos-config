# dwl-bar-refresh
#
# Redraws the bar's status text now rather than at slstatus's next 5 s tick.
# Run by anything that changes what a status block shows (config.h's volume,
# brightness and layout binds, the bar's click regions, dwl-dnd,
# dwl-caffeine, dwl-nightlight, dwl-powersave, dwl-settings).

pkill -USR1 -x slstatus || true
