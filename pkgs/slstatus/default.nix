# pkgs/slstatus/default.nix
#
# slstatus with this repo's config.h, feeding dwl's built-in bar (dwl reads the
# status line from its stdin; see modules/features/dwl.nix). The volume
# readout shells out to wpctl because slstatus's own vol_perc is OSS/ALSA only.

{
  slstatus,
  replaceVars,
  writeShellScript,
  wireplumber,
  gawk,
}:

let
  volume = writeShellScript "slstatus-volume" ''
    ${wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@ \
      | ${gawk}/bin/awk '{ if ($3 == "[MUTED]") print "mute"; else printf "%d%%\n", $2 * 100 }'
  '';
in
slstatus.override {
  conf = replaceVars ./config.h { inherit volume; };
}
