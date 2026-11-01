# slstatus-network
#
# The Wi-Fi network (or "eth" on a wired link), red "off" with the radio
# disabled and "none" when disconnected, then an accent "bt" label
# followed, in the normal colour, by the first connected Bluetooth device's
# name (and +N for more). Each half is its own right-click region (toggling
# Wi-Fi or Bluetooth).

name=
while IFS=: read -r type state conn; do
  case $type:$state in
    wifi:connected) name=$conn ;;
    ethernet:connected) [ -n "$name" ] || name=eth ;;
  esac
done < <(nmcli -t -f TYPE,STATE,CONNECTION device)
name=${name//\\:/:}
name=${name//^/}
printf '^rm(dwl-network --toggle-wifi)'
if [ -n "$name" ]; then
  printf '%s' "${name:0:14}"
elif [ "$(nmcli radio wifi)" = disabled ]; then
  printf '^fg(%s)off^fg()' "$SLSTATUS_ALERT"
else
  printf '^fg(%s)none^fg()' "$SLSTATUS_ALERT"
fi
printf '^rm()'
# Right click toggles Bluetooth, so the entry stays up whenever there is
# an adapter: "bt off" in red, a bare "bt" with nothing connected.
bt=$(timeout 2 bluetoothctl show 2>/dev/null || true)
if [[ $bt == *"Powered: yes"* ]]; then
  bt=$(timeout 2 bluetoothctl devices Connected | sed 's/\x1b\[[0-9;]*m//g' || true)
  printf ' ^rm(dwl-network --toggle-bluetooth)^fg(%s)bt^fg()' "$SLSTATUS_ACCENT"
  if [ -n "$bt" ]; then
    read -r _ _ dev <<<"$(head -n1 <<<"$bt")"
    dev=${dev//^/}
    printf ' %s' "${dev:0:14}"
    n=$(wc -l <<<"$bt")
    [ "$n" -le 1 ] || printf ' +%s' "$((n - 1))"
  fi
  printf '^rm()'
elif [[ $bt == *Powered:* ]]; then
  printf ' ^rm(dwl-network --toggle-bluetooth)^fg(%s)bt off^fg()^rm()' "$SLSTATUS_ALERT"
fi
echo
