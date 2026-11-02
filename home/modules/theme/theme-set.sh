# theme-set {NAME|next|prev|default|list|current|reload}
#
# Switches the palette every my.theme-following app reads, and tells the
# running ones. See runtime.nix for how the pieces fit; this is the CLI.
#
# `NAME` records an override and repoints $THEME_STATE/active at that
# palette's fragments. `default` removes the override and points back at
# my.theme.default as built. `reload` re-runs the reload hooks and nothing
# else. The hooks (reload_all) are appended by runtime.nix.

override="$THEME_STATE/override"
active="$THEME_STATE/active"

list() { printf '%s\n' "$THEME_NAMES"; }

current() {
  if [ -r "$override" ]; then
    cat "$override"
  else
    echo "$THEME_DEFAULT (default)"
  fi
}

# Replace the symlink atomically: apps and watchers must never see it
# missing, and a watcher on the directory gets one rename event.
point_at() {
  mkdir -p "$THEME_STATE"
  ln -sfn "$THEME_PALETTES/$1" "$active.tmp"
  mv -T "$active.tmp" "$active"
}

set_theme() {
  if ! list | grep -qx -- "$1"; then
    echo "theme-set: no palette '$1' (try: theme-set list)" >&2
    exit 1
  fi
  mkdir -p "$THEME_STATE"
  echo "$1" >"$override.tmp"
  mv "$override.tmp" "$override"
  point_at "$1"
  reload_all "$1"
}

# The palette `step` places away from the current one, wrapping.
step() {
  local cur names i=0
  cur=$(current)
  cur=${cur% (default)}
  mapfile -t names < <(list)
  for i in "${!names[@]}"; do
    [ "${names[$i]}" = "$cur" ] && break
  done
  set_theme "${names[$(((i + $1 + ${#names[@]}) % ${#names[@]}))]}"
}

main() {
  case "${1:-}" in
  list) list ;;
  current) current ;;
  reload) reload_all "$([ -r "$override" ] && cat "$override" || true)" ;;
  default)
    rm -f "$override"
    point_at "$THEME_DEFAULT"
    reload_all ""
    ;;
  next) step 1 ;;
  prev) step -1 ;;
  "")
    echo "usage: theme-set {NAME|next|prev|default|list|current|reload}" >&2
    exit 1
    ;;
  *) set_theme "$1" ;;
  esac
}
