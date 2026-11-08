# Notifications and power page: Do Not Disturb, caffeine, power profile,
# battery, and shortcuts to the notification history and the session menu.
# Concatenated into dwl-settings by scripts.nix; relies on common.sh and on
# network.sh's power_menu.
#
# Idle and lock timeouts are not here: hypridle's are fixed in Nix
# (home/modules/hyprland/hypridle.nix), so there is nothing to change at runtime.

dnd_on() { [[ $(makoctl mode) == *do-not-disturb* ]]; }

# dwl-caffeine's idle inhibitor is a systemd-inhibit tagged with this name.
caffeine_on() { pgrep -u "$(id -u)" -f -- '--who=dwl-caffeine' >/dev/null; }

# "81% charging" for the first battery; fails when there is none.
battery_summary() {
  local bat
  for bat in /sys/class/power_supply/BAT*; do
    [ -r "$bat/capacity" ] || continue
    printf '%s%% %s' "$(<"$bat/capacity")" "$(tr '[:upper:]' '[:lower:]' <"$bat/status")"
    return 0
  done
  return 1
}

battery_info() {
  local bat out=''
  for bat in /sys/class/power_supply/BAT*; do
    [ -r "$bat/capacity" ] || continue
    out+="$(basename "$bat"): $(<"$bat/capacity")% $(<"$bat/status")"$'\n'
    # Only some laptops have a charge limit, and setting it needs root.
    if [ -r "$bat/charge_control_end_threshold" ]; then
      out+="  charge limit: $(<"$bat/charge_control_end_threshold")%"$'\n'
    fi
  done
  notice "$out"
}

notifications_summary() {
  local bat
  bat=$(battery_summary || true)
  echo "dnd $(onoff dnd_on) · caffeine $(onoff caffeine_on)${bat:+ · $bat}"
}

notifications_menu() {
  local sel bat
  while :; do
    bat=$(battery_summary || true)
    sel=$(
      {
        printf 'Do Not Disturb  %s\tdnd\n' "$(onoff dnd_on)"
        printf 'Caffeine        %s\tcaffeine\n' "$(onoff caffeine_on)"
        printf 'Power profile   %s\tprofile\n' "$(powerprofilesctl get)"
        if [ -n "$bat" ]; then
          printf 'Battery         %s\tbattery\n' "$bat"
        fi
        printf 'Notification history\thistory\n'
        printf 'Session (lock, suspend, power off)\tsession\n'
      } | pick notifications
    ) || return 0
    case ${sel#*$'\t'} in
      dnd) dwl-dnd ;;
      caffeine) dwl-caffeine ;;
      profile) power_menu ;;
      battery) battery_info ;;
      # Hand over to the other popup; this one is done.
      history) dwl-modal notifications; exit 0 ;;
      session) dwl-modal session; exit 0 ;;
      *) ;;
    esac
  done
}
