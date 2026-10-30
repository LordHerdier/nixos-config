# dwl-nightlight
#
# Toggles a fixed warm screen temperature, standing in for Noctalia's
# nightlight-toggle under Hyprland (temperature_night = 4000 in
# home/modules/noctalia.nix). wlsunset with no location or manual times
# treats every hour as polar night and holds -t; -T only has to be higher.
# The tint lasts as long as wlsunset runs, so toggling off is killing it.

if pkill -u "$(id -u)" -x wlsunset; then
  notify-send -a "Night light" "Night light off"
  exit 0
fi

setsid -f wlsunset -t 4000 -T 4001 >/dev/null 2>&1
notify-send -a "Night light" "Night light on"
