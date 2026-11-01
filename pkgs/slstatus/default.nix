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
  # (dwl-dnd). Nerd Font icons draw past their one-cell advance (the bell to
  # about 1.4 cells, the crossed-out one nearly 2), and dwl's bar clips each
  # block to its advance, so the trailing space gives them room.
  notifications = writeShellScript "slstatus-notifications" ''
    if ${mako}/bin/makoctl mode | ${gnugrep}/bin/grep -qx do-not-disturb; then
      printf '^fg(${alert})\uf1f6 ^fg()\n'
    else
      printf '^fg(${noHash accent})\uf0f3 ^fg()\n'
    fi
  '';
in
slstatus.override {
  conf = replaceVars ./config.h {
    inherit volume battery notifications;
    accent = noHash accent;
    muted = noHash muted;
    # wpctl's own @DEFAULT_AUDIO_SINK@ in the click commands, not ours
    DEFAULT_AUDIO_SINK = null;
  };
}
