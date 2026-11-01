# slstatus-keyboard
#
# The active keyboard layout, which dwl writes on every change
# (89-xkb-layout.patch): Colemak plain, anything else in the accent colour
# so typing in QWERTY by mistake stands out.

read -r name <"$XDG_RUNTIME_DIR/dwl-xkb-layout" || exit 1
case $name in
  *Colemak*) echo cmk ;;
  "English (US)") printf '^fg(%s)qwerty^fg()\n' "$SLSTATUS_ACCENT" ;;
  *) printf '^fg(%s)%s^fg()\n' "$SLSTATUS_ACCENT" "$name" ;;
esac
