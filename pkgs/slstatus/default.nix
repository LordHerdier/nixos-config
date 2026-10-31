# pkgs/slstatus/default.nix
#
# slstatus with this repo's config.h, feeding dwl's built-in bar (dwl reads the
# status line from its stdin; see modules/features/dwl.nix). The volume
# readout shells out to wpctl because slstatus's own vol_perc is OSS/ALSA only.
# Both scripts print dwl's inline ^fg() colour commands
# (95-bar-status-commands.patch) so their colour follows the state.

{
  slstatus,
  replaceVars,
  writeShellScript,
  wireplumber,
  gawk,
}:

let
  # Colours as rrggbb, matching pkgs/dwl/config.h's purple scheme.
  alert = "f38ba8";
  good = "a6e3a1";

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
in
slstatus.override {
  conf = replaceVars ./config.h {
    inherit volume battery;
    # wpctl's own @DEFAULT_AUDIO_SINK@ in the click commands, not ours
    DEFAULT_AUDIO_SINK = null;
  };
}
