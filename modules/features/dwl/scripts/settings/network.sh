# Network page: Wi-Fi, Bluetooth, power profile, airplane mode, Ethernet,
# VPN and IP addresses. Concatenated into dwl-settings by scripts.nix;
# relies on common.sh.

wifi_on() { [ "$(nmcli radio wifi)" = enabled ]; }

bt_on() {
  local out
  out=$(bluetoothctl show 2>/dev/null || true)
  [[ $out == *"Powered: yes"* ]]
}

toggle_wifi() {
  if wifi_on; then nmcli radio wifi off; else nmcli radio wifi on; fi
  dwl-bar-refresh
}

toggle_bluetooth() {
  if bt_on; then
    bluetoothctl power off >/dev/null
  else
    rfkill unblock bluetooth || true
    bluetoothctl power on >/dev/null
  fi
  dwl-bar-refresh
}

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

wifi_rows() {
  if ! wifi_on; then
    printf 'Turn Wi-Fi on\ttoggle\n'
    return
  fi
  printf 'Turn Wi-Fi off\ttoggle\nRescan\trescan\nForget a saved network\tforget\n'
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
      forget) forget_menu ;;
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
        dwl-bar-refresh
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
        dwl-bar-refresh
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

forget_menu() {
  local sel line name
  sel=$(
    nmcli -t -f NAME,TYPE con show | while read -r line; do
      [ "${line##*:}" = 802-11-wireless ] || continue
      name=${line%:*}
      name=${name//\\:/:}
      printf '%s\t%s\n' "$name" "$name"
    done | pick forget
  ) || return 0
  name=${sel#*$'\t'}
  if confirm "forget $name?"; then
    nmcli con delete id "$name" || pause
  fi
}

# Airplane mode is every radio soft blocked; no radios counts as off.
airplane_on() {
  local soft
  soft=$(rfkill -n -o SOFT list 2>/dev/null || true)
  [ -n "$soft" ] && ! grep -qx unblocked <<<"$soft"
}

toggle_airplane() {
  if airplane_on; then rfkill unblock all; else rfkill block all; fi
  dwl-bar-refresh
}

# "device<TAB>state" of the first Ethernet device, if there is one.
ethernet_device() {
  nmcli -t -f DEVICE,TYPE,STATE dev | awk -F: '$2 == "ethernet" { print $1 "\t" $3; exit }'
}

toggle_ethernet() {
  local dev state
  IFS=$'\t' read -r dev state <<<"$(ethernet_device)"
  case $state in
    connected*) nmcli dev disconnect "$dev" || pause ;;
    disconnected) nmcli dev connect "$dev" || pause ;;
    *) notice "$dev is $state (is a cable plugged in?)" ;;
  esac
  dwl-bar-refresh
}

# NAME<TAB>1 if up, else 0, for each saved VPN or WireGuard connection.
vpn_connections() {
  local active line name on
  active=$(nmcli -t -f NAME,TYPE con show --active)
  nmcli -t -f NAME,TYPE con show | while read -r line; do
    case ${line##*:} in
      vpn | wireguard) ;;
      *) continue ;;
    esac
    name=${line%:*}
    name=${name//\\:/:}
    on=0
    if grep -Fxq -- "$line" <<<"$active"; then on=1; fi
    printf '%s\t%s\n' "$name" "$on"
  done
}

vpn_menu() {
  local sel name on
  while :; do
    sel=$(
      vpn_connections | while IFS=$'\t' read -r name on; do
        if [ "$on" = 1 ]; then
          printf '* %-40s up\t%s\t%s\n' "$name" "$name" "$on"
        else
          printf '  %-40s down\t%s\t%s\n' "$name" "$name" "$on"
        fi
      done | pick vpn
    ) || return 0
    IFS=$'\t' read -r _ name on <<<"$sel"
    if [ "$on" = 1 ]; then
      nmcli con down id "$name" || pause
    else
      nmcli con up id "$name" || pause
    fi
    dwl-bar-refresh
  done
}

ip_info() {
  local out
  out=$(nmcli -t -f GENERAL.DEVICE,IP4.ADDRESS dev show | awk -F: '
    /^GENERAL.DEVICE/ { d = $2 }
    /^IP4.ADDRESS/ && d != "lo" { print d ": " $2 }')
  notice "${out:-no addresses}"
}

# One line for the top level.
network_summary() {
  local wifi
  if wifi_on; then
    wifi=$(wifi_name)
    echo "${wifi:-not connected}"
  else
    echo off
  fi
}

network_menu() {
  local wifi bt n sel eth vpns
  while :; do
    eth=$(ethernet_device || true)
    vpns=$(vpn_connections || true)
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
        printf 'Airplane mode  %s\tairplane\n' "$(onoff airplane_on)"
        if [ -n "$eth" ]; then
          printf 'Ethernet       %s\tethernet\n' "${eth#*$'\t'}"
        fi
        if [ -n "$vpns" ]; then
          printf 'VPN            %s\tvpn\n' "$(awk -F'\t' '$2 == 1 { up++ } END { printf "%d up of %d", up, NR }' <<<"$vpns")"
        fi
        printf 'IP addresses\tip\n'
      } | pick network
    ) || return 0
    case ${sel#*$'\t'} in
      wifi) wifi_menu ;;
      bt) bt_menu ;;
      power) power_menu ;;
      airplane) toggle_airplane ;;
      ethernet) toggle_ethernet ;;
      vpn) vpn_menu ;;
      ip) ip_info ;;
      *) ;;
    esac
  done
}
