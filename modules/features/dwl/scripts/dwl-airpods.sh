# dwl-airpods
#
# Cycles the AirPods' noise control (Super+Alt+S), standing in for the
# harveywuk/airpods Noctalia plugin's cycle-noise: off, transparency, adaptive,
# ANC, skipping modes the model lacks, the same order and rules as the
# plugin. The state comes from the status file the librepods daemon (started
# by dwl-startup) keeps, and the change goes through librepods-ctl.

status=${XDG_STATE_HOME:-$HOME/.local/state}/librepods/status.json

# librepods removes the file when it exits.
if ! [ -s "$status" ]; then
  notify-send -a AirPods "LibrePods isn't running"
  exit 1
fi

# "current mode" then the cycle, one per line; nothing when not connected and
# just "none" without noise control. Missing support flags default the way the
# plugin's parseStatus does.
mapfile -t modes < <(jq -r '
  def name: {"0": "off", "1": "anc", "2": "transparency", "3": "adaptive"}[tostring] // "";
  if .connected != true then empty
  elif .supports_noise_control == false then "none"
  else
    (.noise_mode // -1 | name),
    (if .supports_noise_off == false then empty else 0 end | name),
    (2 | name),
    (if has("supports_adaptive") then .supports_adaptive else .is_pro_series end
      | if . == true then 3 | name else empty end),
    (1 | name)
  end' "$status")

if [ ${#modes[@]} -eq 0 ]; then
  notify-send -a AirPods "AirPods aren't connected"
  exit 1
fi
if [ "${modes[0]}" = none ]; then
  notify-send -a AirPods "These AirPods have no noise control"
  exit 1
fi

# The mode after the current one; an unknown current mode starts the cycle.
current=${modes[0]}
cycle=("${modes[@]:1}")
next=${cycle[0]}
for i in "${!cycle[@]}"; do
  if [ "${cycle[$i]}" = "$current" ]; then
    next=${cycle[$(((i + 1) % ${#cycle[@]}))]}
    break
  fi
done

if ! err=$(librepods-ctl "noise:$next" 2>&1); then
  notify-send -a AirPods "Couldn't change noise control" "$err"
  exit 1
fi

case $next in
  off) label=Off ;;
  anc) label="Noise cancellation" ;;
  transparency) label=Transparency ;;
  adaptive) label=Adaptive ;;
esac
notify-send -a AirPods "Noise control: $label"
