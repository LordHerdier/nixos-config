# dwl-settings [network | --toggle-wifi | --toggle-bluetooth]
#
# Settings menu in a centred kitty popup (Super+/), standing in for
# Noctalia's control centre: one row per page with a live summary; Escape
# goes back a level, then closes. Each page is a file in ./settings that
# scripts.nix concatenates ahead of this one (after common.sh, the shared
# helpers), so a new page needs its functions, an entry in scripts.nix's
# `pages`, and rows in the cases below.
#
# A page name opens that page directly (dwl-modal's "network": Super+Alt+A
# and the bar's net block). --toggle-wifi / --toggle-bluetooth are the bar
# block's right clicks; --swatch is the palette picker's preview.

case ${1:-} in
  --toggle-wifi) toggle_wifi; exit 0 ;;
  --toggle-bluetooth) toggle_bluetooth; exit 0 ;;
  --swatch) swatch "${2:-default}"; exit 0 ;;
  network) network_menu; exit 0 ;;
  sound) sound_menu; exit 0 ;;
  display) display_menu; exit 0 ;;
  appearance) appearance_menu; exit 0 ;;
  input) input_menu; exit 0 ;;
  notifications) notifications_menu; exit 0 ;;
  system) system_menu; exit 0 ;;
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
      printf 'Display                %s\tdisplay\n' "$(display_summary)"
      printf 'Appearance             %s\tappearance\n' "$(appearance_summary)"
      printf 'Input                  %s\tinput\n' "$(input_summary)"
      printf 'Notifications & power  %s\tnotifications\n' "$(notifications_summary)"
      printf 'System                 %s\tsystem\n' "$(system_summary)"
    } | pick settings
  ) || exit 0
  case ${sel#*$'\t'} in
    network) network_menu ;;
    sound) sound_menu ;;
    display) display_menu ;;
    appearance) appearance_menu ;;
    input) input_menu ;;
    notifications) notifications_menu ;;
    system) system_menu ;;
    *) ;;
  esac
done
