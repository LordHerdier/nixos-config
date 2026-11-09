# slstatus-network
#
# Wi-Fi/Ethernet then Bluetooth. The network half is "W" (Wi-Fi), "E"
# (Ethernet), "WE" (both) or "-" (nothing; alert colour when the Wi-Fi radio
# is off); Bluetooth "+" or "-". Hovering shows the network or device name
# (first connected device, +N for more), or "off" / "none", through dwl's
# ^hv() (81-bar-status-hover.patch). Right-clicking either half toggles
# Wi-Fi or Bluetooth. config.h prints the "net" label, this the "bt" one.

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
printf '^rm(dwl-settings --toggle-wifi)'
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
  printf ' ^rm(dwl-settings --toggle-bluetooth)^fg(%s)bt^fg() ' "$SLSTATUS_ACCENT"
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
  printf ' ^rm(dwl-settings --toggle-bluetooth)^fg(%s)bt^fg() ^fg(%s)^hv(off)-^hv()^fg()^rm()' "$SLSTATUS_ACCENT" "$SLSTATUS_ALERT"
fi
echo
