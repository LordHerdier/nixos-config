# dwl-theme {NAME|file PATH|next|prev|default|list|current|reload}
#
# Switches the colours of the running dwl (bar, tray, borders, background)
# between the my.theme palettes without a rebuild or a restart.
#
# Every palette is a colours file in $DWL_THEMES, one per my.theme.palettes
# entry. dwl reads $XDG_STATE_HOME/dwl/colors if there is one and
# /etc/dwl/colors (my.theme.default, as built) if not, at startup and on
# SIGUSR2. So `NAME` installs that palette's file as the override and signals
# dwl, and `default` removes the override, which goes back to whatever the
# last rebuild set. A rebuild that changes my.theme.default recolours dwl
# the same way (see default.nix), but only when no override is in place.
#
# This only recolours what dwl draws, which includes slstatus's blocks since
# they print dwl's colour names. mako, st-wl and the other apps follow
# `theme-set` instead, through their my.theme fragments (home/modules/theme/
# runtime.nix), whose dwl hook calls this script.

themes="${DWL_THEMES:?}"
system=/etc/dwl/colors
override="${XDG_STATE_HOME:-$HOME/.local/state}/dwl/colors"

# The "# NAME" first line the colours files start with.
name_of() { sed -n '1s/^# //p' "$1" 2>/dev/null || true; }

list() { ls "$themes"; }

current() {
  if [ -r "$override" ]; then
    name_of "$override"
  else
    echo "$(name_of "$system") (default)"
  fi
}

# Signal only the dwl this script was built with. A dwl from before this
# patch has no SIGUSR2 handler and would die of it.
reload() {
  local pid
  for pid in $(pgrep -x dwl); do
    [ "$(readlink "/proc/$pid/exe")" = "${DWL_BIN:?}" ] && kill -USR2 "$pid"
  done
  return 0
}

set_theme() {
  [ -f "$themes/$1" ] || {
    echo "dwl-theme: no palette '$1' (try: dwl-theme list)" >&2
    exit 1
  }
  mkdir -p "$(dirname "$override")"
  cp "$themes/$1" "$override.tmp"
  mv "$override.tmp" "$override"
  reload
}

# A colours file that is not one of the built palettes (theme-set wal).
set_file() {
  [ -f "${1:-}" ] || {
    echo "dwl-theme: not a file: ${1:-}" >&2
    exit 1
  }
  mkdir -p "$(dirname "$override")"
  cp "$1" "$override.tmp"
  mv "$override.tmp" "$override"
  reload
}

# The palette `step` places away from the current one, wrapping.
step() {
  local cur names i
  cur=$(current)
  cur=${cur% (default)}
  mapfile -t names < <(list)
  for i in "${!names[@]}"; do
    [ "${names[$i]}" = "$cur" ] && break
  done
  set_theme "${names[$(((i + $1 + ${#names[@]}) % ${#names[@]}))]}"
}

case "${1:-}" in
list) list ;;
current) current ;;
reload) reload ;;
default)
  rm -f "$override"
  reload
  ;;
file) set_file "${2:-}" ;;
next) step 1 ;;
prev) step -1 ;;
"")
  echo "usage: dwl-theme {NAME|file PATH|next|prev|default|list|current|reload}" >&2
  exit 1
  ;;
*) set_theme "$1" ;;
esac
