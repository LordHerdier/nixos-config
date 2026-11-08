# dwl-settings [network | --toggle-wifi | --toggle-bluetooth]
#
# General settings menu in a centred st-wl popup (Super+/, via dwl-modal),
# standing in for Noctalia's control centre. The top level lists one row per
# page, each with a live summary; Escape goes back a level, then closes.
# Every page is a file in ./settings, concatenated ahead of this one by
# scripts.nix, so a page only has to define its functions and be added to
# the list below; common.sh holds what they share (pick, pause).
#
# Pages so far: network (Wi-Fi, Bluetooth, power profile), sound, appearance,
# notifications (with power). Planned: display, input, system info.
#
# A page name (network, sound, appearance, notifications) opens that page
# directly: Super+Alt+A and the bar's net block use `network`, through
# dwl-modal's "network" entry. --toggle-wifi and --toggle-bluetooth are for the
# bar block: right clicking the Wi-Fi name or the Bluetooth entry toggles that
# one without opening the popup. --swatch is the palette picker's preview.

case ${1:-} in
  --toggle-wifi) toggle_wifi; exit 0 ;;
  --toggle-bluetooth) toggle_bluetooth; exit 0 ;;
  --swatch) swatch "${2:-default}"; exit 0 ;;
  network) network_menu; exit 0 ;;
  sound) sound_menu; exit 0 ;;
  appearance) appearance_menu; exit 0 ;;
  notifications) notifications_menu; exit 0 ;;
  "") ;;
  *)
    echo "dwl-settings: unknown page '$1'" >&2
    exit 2
    ;;
esac

while :; do
  sel=$(
    {
      printf 'Network                %s\tnetwork\n' "$(network_summary)"
      printf 'Sound                  %s\tsound\n' "$(sound_summary)"
      printf 'Appearance             %s\tappearance\n' "$(appearance_summary)"
      printf 'Notifications & power  %s\tnotifications\n' "$(notifications_summary)"
    } | pick settings
  ) || exit 0
  case ${sel#*$'\t'} in
    network) network_menu ;;
    sound) sound_menu ;;
    appearance) appearance_menu ;;
    notifications) notifications_menu ;;
    *) ;;
  esac
done
