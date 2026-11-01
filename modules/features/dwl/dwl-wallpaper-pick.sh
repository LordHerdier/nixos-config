# dwl-wallpaper-pick
#
# fzf menu over the dwl-wallpaper images, run in a centred kitty popup (Super+Alt+4
# in pkgs/dwl/config.h) so the preview pane can show thumbnails with kitty icat.
# Each entry is applied as the cursor lands on it, but only once the cursor has
# rested there for a moment: dwl-wallpaper starts a fresh swaybg per change, so
# holding an arrow key would otherwise pile them up. Enter keeps the highlighted
# wallpaper, Esc puts back the one that was up when the menu opened.
#
# The pause works through a "pending" file holding the newest entry. Every
# focus change writes it and starts a background apply that sleeps, then only
# goes ahead if the file still names its entry. Deleting the file on exit
# cancels whatever is still waiting.

delay=0.25

# Internal: called by fzf's focus binding below.
if [ "${1:-}" = --apply-later ]; then
  pending=$2
  pick=$3
  printf '%s\n' "$pick" >"$pending"
  (
    sleep "$delay"
    [ "$(cat "$pending" 2>/dev/null)" = "$pick" ] && dwl-wallpaper set "$pick"
  ) </dev/null >/dev/null 2>&1 &
  exit 0
fi

state="${XDG_STATE_HOME:-$HOME/.local/state}/dwl-wallpaper"
orig=""
[ -r "$state" ] && orig=$(<"$state")

mapfile -t files < <(dwl-wallpaper list)
[ "${#files[@]}" -gt 0 ] || exit 1

# Start the cursor on the wallpaper that is up now (fzf positions are 1-based).
pos=1
for i in "${!files[@]}"; do
  if [ "${files[$i]}" = "$orig" ]; then
    pos=$((i + 1))
    break
  fi
done

pending=$(mktemp -t dwl-wallpaper-pick.XXXXXX)
trap 'rm -f "$pending"' EXIT
# Pressing Super+Alt+4 again closes the kitty (dwl-modal), which hangs up
# fzf. Outlive that hangup so the code below still puts back the original
# wallpaper, the same as Esc.
trap : HUP TERM

# shellcheck disable=SC2016 # FZF_PREVIEW_* are expanded by fzf's preview shell
sel=$(
  printf '%s\n' "${files[@]}" | fzf \
    --delimiter / --with-nth -1 \
    --layout reverse --prompt 'wallpaper> ' \
    --preview-window right,65%,border-left \
    --preview 'kitty icat --clear --transfer-mode=memory --unicode-placeholder --stdin=no --place="${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}@0x0" {}' \
    --bind "load:pos($pos)" \
    --bind "focus:execute-silent($0 --apply-later $pending {})"
) || true

rm -f "$pending"

if [ -n "$sel" ]; then
  # The pause may not have run out on the final entry yet.
  [ "$(cat "$state" 2>/dev/null)" = "$sel" ] || dwl-wallpaper set "$sel"
elif [ -n "$orig" ] && [ -f "$orig" ]; then
  dwl-wallpaper set "$orig"
fi
