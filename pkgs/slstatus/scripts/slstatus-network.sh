# slstatus-network
#
# Wi-Fi/Ethernet then Bluetooth. The network half collapses to "W" (Wi-Fi),
# "E" (Ethernet), "WE" (both) or "-" (nothing connected, red when the Wi-Fi
# radio is off); Bluetooth to "+" or "-". Hover expands to the network or
# device name, or "off" / "none". The expansion is a dwl ^hv()
# region (99-z-bar-status-hover.patch). Each half is also its own
# right-click region (toggling Wi-Fi or Bluetooth). The first connected
# Bluetooth device's name gets +N for more. The "net" label comes from
# slstatus's config.h, the "bt" one is printed here.

name=
flag=
eth=
while IFS=: read -r type state conn; do
  case $type:$state in
    wifi:connected) name=$conn flag+=W ;;
    ethernet:connected) eth=eth flag+=E ;;
  esac
done < <(nmcli -t -f TYPE,STATE,CONNECTION device)
# Keep W before E whatever order nmcli lists them in
[[ $flag == EW ]] && flag=WE
if [ -n "$eth" ]; then
  name=${name:+$name, }eth
fi
name=${name//\\:/:}
# ^ and ) would end or escape a ^hv() region
name=${name//[\^)]/}
printf '^rm(dwl-network --toggle-wifi)'
if [ -n "$name" ]; then
  printf '^hv(%s)%s^hv()' "$name" "$flag"
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
