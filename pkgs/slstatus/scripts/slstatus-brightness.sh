# slstatus-brightness
#
# Backlight percentage, in the accent colour while dwl-nightlight's
# wlsunset tint is on.

# NR == 1 rather than exiting early, which could SIGPIPE brightnessctl and
# fail the pipeline.
pct=$(brightnessctl -m -c backlight | awk -F, 'NR == 1 { print $4 }')
[ -n "$pct" ] || exit 1
if pgrep -u "$(id -u)" -x wlsunset >/dev/null; then
  printf '^fg(%s)%s^fg()\n' "$SLSTATUS_ACCENT" "$pct"
else
  echo "$pct"
fi
