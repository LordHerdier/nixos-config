# slstatus-network
#
# Wi-Fi then Bluetooth, each collapsed to "+" (connected) or "-" (nothing
# connected, red when the radio is off) and expanded on hover to the
# network or device name, or "off" / "none". The expansion is a dwl ^hv()
# region (99-z-bar-status-hover.patch). Each half is also its own
# right-click region (toggling Wi-Fi or Bluetooth). The first connected
# Bluetooth device's name gets +N for more. The "net" label comes from
# slstatus's config.h, the "bt" one is printed here.

name=
while IFS=: read -r type state conn; do
  case $type:$state in
    wifi:connected) name=$conn ;;
    ethernet:connected) [ -n "$name" ] || name=eth ;;
  esac
done < <(nmcli -t -f TYPE,STATE,CONNECTION device)
name=${name//\\:/:}
# ^ and ) would end or escape a ^hv() region
name=${name//[\^)]/}
printf '^rm(dwl-network --toggle-wifi)'
if [ -n "$name" ]; then
  printf '^hv(%s)+^hv()' "$name"
elif [ "$(nmcli radio wifi)" = disabled ]; then
  printf '^fg(%s)^hv(off)-^hv()^fg()' "$SLSTATUS_ALERT"
else
  printf '^hv(none)-^hv()'
fi
printf '^rm()'
# Right click toggles Bluetooth, so the entry stays up whenever there is
# an adapter.
bt=$(timeout 2 bluetoothctl show 2>/dev/null || true)
if [[ $bt == *"Powered: yes"* ]]; then
  bt=$(timeout 2 bluetoothctl devices Connected | sed 's/\x1b\[[0-9;]*m//g' || true)
  printf ' ^rm(dwl-network --toggle-bluetooth)^fg(%s)bt^fg() ' "$SLSTATUS_ACCENT"
  if [ -n "$bt" ]; then
    read -r _ _ dev <<<"$(head -n1 <<<"$bt")"
    dev=${dev//[\^)]/}
    n=$(wc -l <<<"$bt")
    [ "$n" -le 1 ] || dev+=" +$((n - 1))"
    printf '^hv(%s)+^hv()' "$dev"
  else
    printf '^hv(none)-^hv()'
  fi
  printf '^rm()'
elif [[ $bt == *Powered:* ]]; then
  printf ' ^rm(dwl-network --toggle-bluetooth)^fg(%s)bt^fg() ^fg(%s)^hv(off)-^hv()^fg()^rm()' "$SLSTATUS_ACCENT" "$SLSTATUS_ALERT"
fi
echo
