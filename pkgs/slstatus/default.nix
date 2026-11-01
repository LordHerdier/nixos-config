# pkgs/slstatus/default.nix
#
# slstatus with this repo's config.h, feeding dwl's built-in bar (dwl reads the
# status line from its stdin; see modules/features/dwl.nix). The volume
# readout shells out to wpctl because slstatus's own vol_perc is OSS/ALSA only.
# The scripts print dwl's inline ^fg() colour commands
# (95-bar-status-commands.patch) so their colour follows the state.
#
# Colours are #rrggbb parameters defaulting to the OneShot palette;
# modules/features/dwl.nix overrides them from `my.theme`.

{
  lib,
  slstatus,
  replaceVars,
  writeShellScript,
  wireplumber,
  gawk,
  gnugrep,
  mako,
  procps,
  brightnessctl,
  networkmanager,
  bluez,
  coreutils,
  accent ? "#9664ff",
  muted ? "#4a3d66",
  error ? "#6442a5",
  success ? "#9664ff",
}:

let
  # dwl's ^fg() takes rrggbb without the #.
  noHash = lib.removePrefix "#";
  alert = noHash error;
  good = noHash success;

  volume = writeShellScript "slstatus-volume" ''
    ${wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@ \
      | ${gawk}/bin/awk '{ if ($3 == "[MUTED]") print "^fg(${alert})mute^fg()"; else printf "%d%%\n", $2 * 100 }'
  '';

  # Capacity plus + charging, - discharging, o otherwise (full / not
  # charging): red at 15% or less while discharging, green while charging.
  battery = writeShellScript "slstatus-battery" ''
    bat=/sys/class/power_supply/BAT1
    read -r cap < "$bat/capacity" || exit 1
    read -r state < "$bat/status"
    case $state in
      Charging) printf '^fg(${good})%s%% +^fg()\n' "$cap" ;;
      Discharging)
        if [ "$cap" -le 15 ]; then
          printf '^fg(${alert})%s%% -^fg()\n' "$cap"
        else
          printf '%s%% -\n' "$cap"
        fi
        ;;
      *) printf '%s%% o\n' "$cap" ;;
    esac
  '';

  # Nerd Font bell, crossed out while mako's do-not-disturb mode is on
  # (dwl-dnd), after a coffee cup while dwl-caffeine's idle inhibitor runs.
  # Nerd Font icons draw past their one-cell advance (the bell to about 1.4
  # cells, the crossed-out one nearly 2), and dwl's bar clips each block to
  # its advance, so the trailing spaces give them room.
  notifications = writeShellScript "slstatus-notifications" ''
    if ${procps}/bin/pgrep -u "$(id -u)" -f -- '--who=dwl-caffeine' >/dev/null; then
      printf '^fg(${noHash accent})\uf0f4 ^fg()'
    fi
    if ${mako}/bin/makoctl mode | ${gnugrep}/bin/grep -qx do-not-disturb; then
      printf '^fg(${alert})\uf1f6 ^fg()\n'
    else
      printf '^fg(${noHash accent})\uf0f3 ^fg()\n'
    fi
  '';

  # Backlight percentage, in the accent colour while dwl-nightlight's
  # wlsunset tint is on.
  brightness = writeShellScript "slstatus-brightness" ''
    pct=$(${brightnessctl}/bin/brightnessctl -m -c backlight | ${gawk}/bin/awk -F, '{ print $4; exit }')
    [ -n "$pct" ] || exit 1
    if ${procps}/bin/pgrep -u "$(id -u)" -x wlsunset >/dev/null; then
      printf '^fg(${noHash accent})%s^fg()\n' "$pct"
    else
      echo "$pct"
    fi
  '';

  # The Wi-Fi network (or "eth" on a wired link), red "off" with the radio
  # disabled and "none" when disconnected, then a "bt" in the accent colour
  # while a Bluetooth device is connected (count after it from two up).
  network = writeShellScript "slstatus-network" ''
    name=
    while IFS=: read -r type state conn; do
      case $type:$state in
        wifi:connected) name=$conn ;;
        ethernet:connected) [ -n "$name" ] || name=eth ;;
      esac
    done < <(${networkmanager}/bin/nmcli -t -f TYPE,STATE,CONNECTION device)
    name=''${name//\\:/:}
    name=''${name//^/}
    if [ -n "$name" ]; then
      printf '%s' "''${name:0:14}"
    elif [ "$(${networkmanager}/bin/nmcli radio wifi)" = disabled ]; then
      printf '^fg(${alert})off^fg()'
    else
      printf '^fg(${alert})none^fg()'
    fi
    n=$(${coreutils}/bin/timeout 2 ${bluez}/bin/bluetoothctl devices Connected | ${coreutils}/bin/wc -l)
    if [ "$n" -gt 1 ]; then
      printf ' ^fg(${noHash accent})bt %s^fg()' "$n"
    elif [ "$n" -eq 1 ]; then
      printf ' ^fg(${noHash accent})bt^fg()'
    fi
    echo
  '';

  # The active keyboard layout, which dwl writes on every change
  # (89-xkb-layout.patch): Colemak plain, anything else in the accent colour
  # so typing in QWERTY by mistake stands out.
  keyboard = writeShellScript "slstatus-keyboard" ''
    read -r name < "$XDG_RUNTIME_DIR/dwl-xkb-layout" || exit 1
    case $name in
      *Colemak*) echo cmk ;;
      "English (US)") echo '^fg(${noHash accent})qwerty^fg()' ;;
      *) printf '^fg(${noHash accent})%s^fg()\n' "$name" ;;
    esac
  '';
in
slstatus.override {
  conf = replaceVars ./config.h {
    inherit
      volume
      battery
      notifications
      keyboard
      brightness
      network
      ;
    accent = noHash accent;
    muted = noHash muted;
    # wpctl's own @DEFAULT_AUDIO_SINK@ in the click commands, not ours
    DEFAULT_AUDIO_SINK = null;
  };
}
