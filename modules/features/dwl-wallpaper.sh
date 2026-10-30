# dwl-wallpaper {next|prev|rand|restore|set FILE|list}
#
# Cycles through the images in ~/Pictures/Wallpapers (sorted by name) and shows
# the current one with swaybg. The current file is remembered in
# $XDG_STATE_HOME/dwl-wallpaper so `restore` (run at session start) and the
# next/prev steps pick up where the last run left off. `set` shows one given
# file and `list` prints the images in cycle order (both for dwl-wallpaper-pick).

dir="${DWL_WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"
state="${XDG_STATE_HOME:-$HOME/.local/state}/dwl-wallpaper"

mapfile -d '' files < <(
  find -L "$dir" -type f \
    \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) \
    -print0 | sort -z
)
n=${#files[@]}
if [ "$n" -eq 0 ]; then
  echo "dwl-wallpaper: no images in $dir" >&2
  exit 1
fi

if [ "${1:-}" = list ]; then
  printf '%s\n' "${files[@]}"
  exit 0
fi

current=""
[ -r "$state" ] && current=$(<"$state")

# Index of the remembered wallpaper, or -1 if it is gone from the directory.
idx=-1
for i in "${!files[@]}"; do
  if [ "${files[$i]}" = "$current" ]; then
    idx=$i
    break
  fi
done

pick=""
case "${1:-}" in
  set)
    pick="${2:-}"
    if [ ! -f "$pick" ]; then
      echo "dwl-wallpaper: not a file: $pick" >&2
      exit 2
    fi
    ;;
  next) idx=$(((idx + 1) % n)) ;;
  prev) idx=$(((idx - 1 + n) % n)) ;;
  rand)
    if [ "$n" -gt 1 ]; then
      new=$idx
      while [ "$new" -eq "$idx" ]; do new=$((RANDOM % n)); done
      idx=$new
    else
      idx=0
    fi
    ;;
  restore) [ "$idx" -lt 0 ] && idx=0 ;;
  *)
    echo "usage: dwl-wallpaper {next|prev|rand|restore|set FILE|list}" >&2
    exit 2
    ;;
esac

[ -n "$pick" ] || pick=${files[$idx]}
mkdir -p "$(dirname "$state")"
printf '%s\n' "$pick" >"$state"

# Start the new swaybg first and only then stop the old ones, so the screen
# never flashes the bare background colour.
# The nixpkgs swaybg is a wrapper, so the process name is ".swaybg-wrapped"
# and `pgrep -x swaybg` matches nothing; match on the command line instead.
mapfile -t old < <(pgrep -u "$(id -u)" -f '(^|/)\.?swaybg(-wrapped)? -m fill' || true)
setsid swaybg -m fill -i "$pick" >/dev/null 2>&1 &
sleep 0.3
[ "${#old[@]}" -gt 0 ] && kill "${old[@]}" 2>/dev/null || true
exit 0
