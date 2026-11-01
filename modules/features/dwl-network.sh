# dwl-network [--toggle-wifi | --toggle-bluetooth]
#
# Wi-Fi, Bluetooth and power-profile menu in a centred kitty popup
# (Super+Alt+A, or left-clicking the bar's net block), standing in for the
# network / Bluetooth / power-profile pages of Noctalia's control centre.
# Super+A stays the audio mixer. Wi-Fi goes through nmcli, Bluetooth through
# bluetoothctl and the profile through powerprofilesctl. Escape goes back a
# level, then closes; connecting to something closes the popup.
#
# The flags are for the bar block: right clicking the Wi-Fi name or the Bluetooth
# entry toggles that one without opening the popup.

refresh() { pkill -USR1 -x slstatus || true; }

wifi_on() { [ "$(nmcli radio wifi)" = enabled ]; }

bt_on() {
  local out
  out=$(bluetoothctl show 2>/dev/null || true)
  [[ $out == *"Powered: yes"* ]]
}

toggle_wifi() {
  if wifi_on; then nmcli radio wifi off; else nmcli radio wifi on; fi
  refresh
}

toggle_bluetooth() {
  if bt_on; then
    bluetoothctl power off >/dev/null
  else
    rfkill unblock bluetooth || true
    bluetoothctl power on >/dev/null
  fi
  refresh
}

case ${1:-} in
  --toggle-wifi) toggle_wifi; exit 0 ;;
  --toggle-bluetooth) toggle_bluetooth; exit 0 ;;
esac

# The connection (SSID) the Wi-Fi device is on, if any. nmcli's terse output
# escapes colons in the name.
wifi_name() {
  local type state conn
  nmcli -t -f TYPE,STATE,CONNECTION device | while IFS=: read -r type state conn; do
    if [ "$type" = wifi ] && [ "$state" = connected ]; then
      echo "${conn//\\:/:}"
    fi
  done
}

# The saved profile for an SSID, which NetworkManager names after the SSID
# plus a number once there is a second one ("The Fast One 1").
wifi_profile() {
  local name type
  nmcli -t -f NAME,TYPE con show | while IFS=: read -r name type; do
    [ "$type" = 802-11-wireless ] || continue
    if [ "$(nmcli -g 802-11-wireless.ssid con show id "$name")" = "$1" ]; then
      echo "$name"
      break
    fi
  done
}

# label<TAB>payload lines on stdin; prints the chosen line.
pick() {
  fzf --delimiter '\t' --with-nth 1 --layout reverse --no-sort \
    --prompt "$1> " --header 'enter: pick · esc: back'
}

pause() {
  printf '\nfailed · press any key'
  read -rsn1 || true
}

wifi_rows() {
  if ! wifi_on; then
    printf 'Turn Wi-Fi on\ttoggle\n'
    return
  fi
  printf 'Turn Wi-Fi off\ttoggle\nRescan\trescan\n'
  local -A seen=()
  local use sig sec ssid
  # The access point in use first, then the strongest, so the dedupe below
  # keeps that one ('*' sorts after ' ', hence the reverse).
  nmcli -t -f IN-USE,SIGNAL,SECURITY,SSID dev wifi list --rescan no \
    | sort -t: -k1,1r -k2,2nr \
    | while IFS=: read -r use sig sec ssid; do
      ssid=${ssid//\\:/:}
      [ -n "$ssid" ] || continue
      [ -z "${seen[$ssid]:-}" ] || continue
      seen[$ssid]=1
      printf '%s %-32s %3s%%  %s\tnet\t%s\t%s\t%s\n' \
        "${use:- }" "$ssid" "$sig" "$sec" "$use" "$sec" "$ssid"
    done
}

wifi_menu() {
  local sel kind use sec ssid known
  while :; do
    sel=$(wifi_rows | pick wifi) || return 0
    IFS=$'\t' read -r _ kind use sec ssid <<<"$sel"
    case $kind in
      toggle) toggle_wifi ;;
      rescan)
        printf 'scanning…\n'
        nmcli dev wifi rescan 2>/dev/null || true
        sleep 3
        ;;
      net)
        if [ "$use" = '*' ]; then
          nmcli con down id "$(wifi_name)" || pause
        else
          known=$(wifi_profile "$ssid")
          if [ -n "$known" ]; then
            nmcli con up id "$known" || { pause; continue; }
          elif [ "$sec" = -- ]; then
            nmcli dev wifi connect "$ssid" || { pause; continue; }
          else
            nmcli --ask dev wifi connect "$ssid" || { pause; continue; }
          fi
        fi
        refresh
        exit 0
        ;;
    esac
  done
}

bt_rows() {
  if ! bt_on; then
    printf 'Turn Bluetooth on\ttoggle\n'
    return
  fi
  printf 'Turn Bluetooth off\ttoggle\nScan for devices (8 s)\tscan\n'
  local connected paired mac name state mark
  connected=$(bluetoothctl devices Connected)
  paired=$(bluetoothctl devices Paired)
  # bluetoothctl colours some names even when piped.
  bluetoothctl devices | sed 's/\x1b\[[0-9;]*m//g' | while read -r _ mac name; do
    state=new mark=' '
    if grep -Fq -- "$mac" <<<"$connected"; then
      state=connected mark='*'
    elif grep -Fq -- "$mac" <<<"$paired"; then
      state=paired
    # Unnamed devices show up as their own address; noise unless paired.
    elif [ "$name" = "${mac//:/-}" ]; then
      continue
    fi
    printf '%s %-32s %s\tdev\t%s\t%s\n' "$mark" "$name" "$state" "$state" "$mac"
  done
}

bt_menu() {
  local sel kind state mac
  while :; do
    sel=$(bt_rows | pick bluetooth) || return 0
    IFS=$'\t' read -r _ kind state mac <<<"$sel"
    case $kind in
      toggle) toggle_bluetooth ;;
      scan)
        printf 'scanning…\n'
        bluetoothctl --timeout 8 scan on >/dev/null || true
        ;;
      dev)
        case $state in
          connected) bluetoothctl disconnect "$mac" || { pause; continue; } ;;
          paired) timeout 20 bluetoothctl connect "$mac" || { pause; continue; } ;;
          *)
            { timeout 30 bluetoothctl pair "$mac" \
              && bluetoothctl trust "$mac" \
              && timeout 20 bluetoothctl connect "$mac"; } || { pause; continue; }
            ;;
        esac
        refresh
        exit 0
        ;;
    esac
  done
}

power_menu() {
  local current sel
  current=$(powerprofilesctl get)
  sel=$(
    powerprofilesctl list | sed -n 's/^[* ] \([a-z-]*\):$/\1/p' \
      | while read -r p; do
        if [ "$p" = "$current" ]; then
          printf '* %s\t%s\n' "$p" "$p"
        else
          printf '  %s\t%s\n' "$p" "$p"
        fi
      done | pick profile
  ) || return 0
  powerprofilesctl set "${sel#*$'\t'}"
}

while :; do
  wifi=$(wifi_name)
  if wifi_on; then wifi=${wifi:-not connected}; else wifi=off; fi
  if bt_on; then
    n=$(bluetoothctl devices Connected | wc -l)
    bt="on · $n connected"
  else
    bt=off
  fi
  sel=$(
    {
      printf 'Wi-Fi          %s\twifi\n' "$wifi"
      printf 'Bluetooth      %s\tbt\n' "$bt"
      printf 'Power profile  %s\tpower\n' "$(powerprofilesctl get)"
    } | pick network
  ) || exit 0
  case ${sel#*$'\t'} in
    wifi) wifi_menu ;;
    bt) bt_menu ;;
    power) power_menu ;;
  esac
done
