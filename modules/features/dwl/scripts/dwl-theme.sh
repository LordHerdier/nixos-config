# dwl-theme {NAME|file PATH|next|prev|default|list|current|reload}
#
# Switches the running dwl's colours (bar, tray, borders, background)
# between the my.theme palettes, live.
#
# $DWL_THEMES holds a colours file per my.theme.palettes entry. dwl reads
# $XDG_STATE_HOME/dwl/colors, else /etc/dwl/colors (my.theme.default, as
# built), at startup and on SIGUSR2. `NAME` installs a palette as that
# override and signals dwl; `default` removes it. A rebuild changing
# my.theme.default recolours dwl too (default.nix), unless overridden.
#
# Only dwl (and so slstatus's blocks) changes. Other apps follow
# `theme-set`, whose dwl hook (home/modules/theme/default.nix) calls this.

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

# Signal only the dwl this script was built with: one from before
# 99-theme-colours.patch has no SIGUSR2 handler and would die of it.
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
