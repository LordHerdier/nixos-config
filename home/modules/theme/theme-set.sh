# theme-set {NAME|wal [IMAGE]|next|prev|default|list|current|reload}
#
# Switches the palette every my.theme-following app reads, and tells the
# running ones. See runtime.nix for how the pieces fit; this is the CLI.
#
# `NAME` records an override and repoints $THEME_STATE/active at that
# palette's fragments. `default` removes the override and points back at
# my.theme.default as built. `reload` re-runs the reload hooks and nothing
# else. The hooks (reload_all) are appended by runtime.nix.
#
# `wal [IMAGE]` derives a palette from IMAGE with pywal. Fragments that opt
# in (`wal = true`) are rendered at build time with placeholder colours;
# build_wal_palette swaps those for wal's real ones into
# $THEME_STATE/wal-palette, which also holds the default palette's files for
# every other fragment, and `active` is pointed there. wal itself recolours
# open terminals (escape sequences) and keeps its output in ~/.cache/wal.
# The image is remembered in $THEME_STATE/wal, so a bare `wal` re-runs the
# last one, and any other `theme-set` command clears it.

override="$THEME_STATE/override"
active="$THEME_STATE/active"
walstate="$THEME_STATE/wal"
walpalette="$THEME_STATE/wal-palette"

list() { printf '%s\n' "$THEME_NAMES"; }

current() {
  if [ -r "$walstate" ]; then
    echo "wal ($(cat "$walstate"))"
  elif [ -r "$override" ]; then
    cat "$override"
  else
    echo "$THEME_DEFAULT (default)"
  fi
}

# Replace the symlink atomically: apps and watchers must never see it
# missing, and a watcher on the directory gets one rename event.
point_at_dir() {
  mkdir -p "$THEME_STATE"
  ln -sfn "$1" "$active.tmp"
  mv -T "$active.tmp" "$active"
}

point_at() { point_at_dir "$THEME_PALETTES/$1"; }

set_theme() {
  if ! list | grep -qx -- "$1"; then
    echo "theme-set: no palette '$1' (try: theme-set list)" >&2
    exit 1
  fi
  mkdir -p "$THEME_STATE"
  rm -f "$walstate"
  echo "$1" >"$override.tmp"
  mv "$override.tmp" "$override"
  point_at "$1"
  reload_all "$1"
}

# The default palette's files, with each wal-enabled fragment replaced by its
# placeholder render with wal's colours substituted in.
build_wal_palette() {
  local colors="${XDG_CACHE_HOME:-$HOME/.cache}/wal/colors.json"
  local sedargs=() sentinel slot val
  while read -r sentinel slot; do
    case "$slot" in
    background | foreground) val=$(jq -r ".special.$slot" "$colors") ;;
    *) val=$(jq -r ".colors.$slot" "$colors") ;;
    esac
    sedargs+=(-e "s/#$sentinel/$val/Ig")
  done <<<"$THEME_WAL_SLOTS"

  rm -rf "$walpalette.tmp"
  mkdir -p "$walpalette.tmp"
  cp -L --no-preserve=mode "$THEME_PALETTES/$THEME_DEFAULT"/* "$walpalette.tmp/"
  local f
  for f in "$THEME_WAL_TEMPLATES"/*; do
    [ -e "$f" ] || continue
    sed "${sedargs[@]}" "$f" >"$walpalette.tmp/$(basename "$f")"
  done
  rm -rf "$walpalette"
  mv "$walpalette.tmp" "$walpalette"
}

set_wal() {
  local img=${1:-}
  if [ -z "$img" ] && [ -r "$walstate" ]; then
    img=$(cat "$walstate")
  fi
  if [ -z "$img" ] || [ ! -f "$img" ]; then
    echo "usage: theme-set wal IMAGE" >&2
    exit 1
  fi
  img=$(realpath -- "$img")
  # -n: leave the wallpaper alone, whatever sets it owns it.
  # -e: skip wal's own app reloads (kitty wants a remote-control socket we
  # don't configure); the escape sequences already recolour open terminals.
  wal -n -e -q -i "$img"
  mkdir -p "$THEME_STATE"
  echo "$img" >"$walstate"
  build_wal_palette
  point_at_dir "$walpalette"
  reload_all ""
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
  wal) set_wal "${2:-}" ;;
  reload)
    if [ -r "$walstate" ]; then
      wal -n -e -q -R
      build_wal_palette
      point_at_dir "$walpalette"
      reload_all ""
    else
      reload_all "$([ -r "$override" ] && cat "$override" || true)"
    fi
    ;;
  default)
    rm -f "$override" "$walstate"
    point_at "$THEME_DEFAULT"
    reload_all ""
    ;;
  next) step 1 ;;
  prev) step -1 ;;
  "")
    echo "usage: theme-set {NAME|wal [IMAGE]|next|prev|default|list|current|reload}" >&2
    exit 1
    ;;
  *) set_theme "$1" ;;
  esac
}
