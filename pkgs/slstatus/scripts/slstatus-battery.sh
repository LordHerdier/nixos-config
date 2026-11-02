# slstatus-battery
#
# Capacity plus + charging, - discharging, o otherwise (full / not
# charging): red at 15% or less while discharging, green while charging.
# Reads the first battery the kernel lists (BAT0 or BAT1, depending on the
# laptop).
#
# Also sends a critical notification and plays a ping the first time the
# charge drops to 15%, 10% and 5% while discharging. The last level
# announced is kept in $XDG_RUNTIME_DIR so the 5s refresh doesn't repeat it,
# and is forgotten once the charger is plugged in or the charge is back over
# 15%. The jobs are detached from stdout, which slstatus reads the block from.

bats=(/sys/class/power_supply/BAT*)
bat=${bats[0]}
read -r cap <"$bat/capacity" || exit 1
read -r state <"$bat/status" || exit 1
warned=${XDG_RUNTIME_DIR:-/tmp}/slstatus-battery-warned
if [ "$state" = Discharging ] && [ "$cap" -le 15 ]; then
  level=15
  [ "$cap" -le 10 ] && level=10
  [ "$cap" -le 5 ] && level=5
  read -r last <"$warned" 2>/dev/null || last=100
  if [ "$level" -lt "$last" ]; then
    echo "$level" >"$warned"
    notify-send -u critical -a battery -h string:x-canonical-private-synchronous:battery \
      "Battery low" "${cap}% remaining" >/dev/null 2>&1 &
    pw-play "$SLSTATUS_PING" >/dev/null 2>&1 &
  fi
else
  rm -f "$warned"
fi

case $state in
  Charging) printf '^fg(%s)%s%% +^fg()\n' "$SLSTATUS_GOOD" "$cap" ;;
  Discharging)
    if [ "$cap" -le 15 ]; then
      printf '^fg(%s)%s%% -^fg()\n' "$SLSTATUS_ALERT" "$cap"
    else
      printf '%s%% -\n' "$cap"
    fi
    ;;
  *) printf '%s%% o\n' "$cap" ;;
esac
