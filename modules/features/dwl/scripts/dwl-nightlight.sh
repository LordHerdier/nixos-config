# dwl-nightlight
#
# Toggles a fixed warm screen temperature (Super+Shift+N), standing in for
# Noctalia's nightlight-toggle (temperature_night = 4000 in
# home/modules/noctalia.nix). wlsunset with no location or times treats
# every hour as polar night and holds -t; -T only has to be higher. The tint
# lasts while wlsunset runs. The bar's brightness is accent-coloured while
# it's on.

if pkill -u "$(id -u)" -x wlsunset; then
  notify-send -a "Night light" "Night light off"
else
  setsid -f wlsunset -t 4000 -T 4001 >/dev/null 2>&1
  notify-send -a "Night light" "Night light on"
fi
dwl-bar-refresh
