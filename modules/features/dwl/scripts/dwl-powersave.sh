# dwl-powersave
#
# Toggles a battery-saving display state (Super+Shift+P): every enabled
# output above 61 Hz drops to a 60 Hz mode of its current size, if it has
# one, and the backlight goes to POWERSAVE_BRIGHTNESS percent (default 30).
# Toggling off restores both. Measured on Index: 60 Hz saves ~0.4 W, and
# 100% -> 30% brightness ~1 W.
#
# What to restore is kept in $XDG_RUNTIME_DIR/dwl-powersave, so the state
# dies with the login session.

state=${XDG_RUNTIME_DIR:?}/dwl-powersave
target=${POWERSAVE_BRIGHTNESS:-30}

if [ -e "$state" ]; then
  # Lines are "mode <output> <WxH@Hz>" or "brightness <raw>".
  while read -r kind a b; do
    case $kind in
      mode) wlr-randr --output "$a" --mode "$b" || true ;;
      brightness) brightnessctl -q -c backlight set "$a" || true ;;
      *) ;;
    esac
  done <"$state"
  rm -f "$state"
  notify-send -a "Power saver" "Power saver off"
else
  {
    wlr-randr --json | jq -r '
      .[] | select(.enabled) | . as $o
      | ($o.modes[] | select(.current)) as $cur
      | select($cur.refresh > 61)
      | first($o.modes[]
          | select(.width == $cur.width and .height == $cur.height
                   and .refresh > 59 and .refresh < 61))
      | "\($o.name) \(.width)x\(.height)@\(.refresh)"
      + " \($cur.width)x\($cur.height)@\($cur.refresh)"' \
      | while read -r out low prev; do
        if wlr-randr --output "$out" --mode "$low"; then
          echo "mode $out $prev"
        fi
      done
    brightnessctl -m -c backlight | awk -F, 'NR == 1 { print "brightness " $3 }'
  } >"$state"
  brightnessctl -q -c backlight set "${target}%" || true
  notify-send -a "Power saver" "Power saver on"
fi
dwl-bar-refresh
