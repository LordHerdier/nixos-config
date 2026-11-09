# slstatus-battery
#
# Capacity plus + charging, - discharging, o otherwise (full / not
# charging): alert colour at 15% or less while discharging, good while
# charging. Reads the first BAT* the kernel lists.
#
# Also notifies and pings the first time the charge drops to 15%, 10% and 5%
# while discharging. The last level announced is kept in $XDG_RUNTIME_DIR so
# the 5 s refresh doesn't repeat it; charging or going back over 15% resets
# it. Those jobs are kept off stdout, which slstatus reads the block from.

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
