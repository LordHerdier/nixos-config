# slstatus-battery
#
# Capacity plus + charging, - discharging, o otherwise (full / not
# charging): red at 15% or less while discharging, green while charging.
# Reads the first battery the kernel lists (BAT0 or BAT1, depending on the
# laptop).

bats=(/sys/class/power_supply/BAT*)
bat=${bats[0]}
read -r cap <"$bat/capacity" || exit 1
read -r state <"$bat/status" || exit 1
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
