# slstatus-volume
#
# The default PipeWire sink's volume, or "mute" in the alert colour.

wpctl get-volume @DEFAULT_AUDIO_SINK@ \
  | awk -v alert="$SLSTATUS_ALERT" '{ if ($3 == "[MUTED]") print "^fg(" alert ")mute^fg()"; else printf "%d%%\n", $2 * 100 }'
