# dwl-wallpaper {next|prev|rand|restore|set FILE|list}
#
# Cycles through the images in ~/Pictures/Wallpapers (sorted by name) with
# swaybg (Super+Alt+1/2/3). The current file is kept in
# $XDG_STATE_HOME/dwl-wallpaper for `restore` (session start) and the next
# step. `set` and `list` are for dwl-wallpaper-pick.
#
# While `theme-set wal` is active a new wallpaper also re-derives the pywal
# colours (theme-set is a Home Manager package, found on PATH); `restore`
# doesn't, as wal already holds that image.

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

# Start the new swaybg before stopping the old ones, so the background never
# flashes. nixpkgs' swaybg is a wrapper (process ".swaybg-wrapped"), so
# match the command line rather than `pgrep -x swaybg`.
mapfile -t old < <(pgrep -u "$(id -u)" -f '(^|/)\.?swaybg(-wrapped)? -m fill' || true)
setsid swaybg -m fill -i "$pick" >/dev/null 2>&1 &
sleep 0.3
[ "${#old[@]}" -gt 0 ] && kill "${old[@]}" 2>/dev/null || true

if [ "${1:-}" != restore ] && [ -e "${XDG_STATE_HOME:-$HOME/.local/state}/theme/wal" ] \
  && command -v theme-set >/dev/null; then
  setsid theme-set wal "$pick" >/dev/null 2>&1 &
fi
exit 0
