# dwl-notifications
#
# Notification centre in a centred st-wl popup (Super+W), standing in for
# Noctalia's control-center panel: fzf over mako's open notifications
# (marked ●) and history, full text in the preview. Enter runs an open one's
# default action, Ctrl+D deletes, Ctrl+X clears all (as the bar bell's
# middle click does), Ctrl+N toggles Do Not Disturb.
#
# Lines are "ID<tab>open|old<tab>text". mako's IDs count up across both
# lists, so one never names two entries.

notifications() {
  {
    makoctl list -j | jq -r '.[] | [.id, "open", "● \(.app_name): \(.summary)"] | @tsv'
    makoctl history -j | jq -r '.[] | [.id, "old", "  \(.app_name): \(.summary)"] | @tsv'
  }
}

header() {
  local dnd=off
  makoctl mode | grep -qx do-not-disturb && dnd=on
  printf 'enter: open · ctrl-d: delete · ctrl-x: clear all · ctrl-n: dnd (%s)\n' "$dnd"
}

# mako can't delete from its history directly. makoctl restore pops the
# newest entry back on screen (keeping its ID), where it can be dismissed
# without history. So restore down to the target, drop it, and dismiss the
# rest again oldest first, which leaves the history in its old order.
delete() {
  local target=$1 state=$2 id i restored=()
  if [ "$state" = open ]; then
    makoctl dismiss -h -n "$target"
    return
  fi
  while id=$(makoctl history -j | jq -e '.[0].id'); do
    makoctl restore
    if [ "$id" = "$target" ]; then
      makoctl dismiss -h -n "$id"
      break
    fi
    restored+=("$id")
  done
  for ((i = ${#restored[@]} - 1; i >= 0; i--)); do
    makoctl dismiss -n "${restored[i]}"
  done
}

# Same trick as delete, for every entry.
clear_all() {
  makoctl dismiss -a -h
  local _
  for _ in $(seq 100); do
    makoctl history -j | jq -e 'length > 0' >/dev/null || break
    makoctl restore
    makoctl dismiss -a -h
  done
}

# Internal: called by fzf's preview and binds below.
case "${1:-}" in
  --list)
    notifications
    exit 0
    ;;
  --header)
    header
    exit 0
    ;;
  --clear)
    clear_all
    exit 0
    ;;
  --delete)
    delete "$2" "$3"
    exit 0
    ;;
  --preview)
    { makoctl list -j; makoctl history -j; } | jq -rs --argjson id "$2" '
      add | map(select(.id == $id)) | first // empty |
      "\(.app_name) · \(.urgency)\n\n\(.summary)\n\n\(.body // "" | gsub("<[^>]*>"; ""))"'
    exit 0
    ;;
esac

sel=$(
  notifications | fzf \
    --delimiter '\t' --with-nth 3 \
    --layout reverse --prompt 'notifications> ' \
    --header "$(header)" \
    --preview-window right,55%,border-left,wrap \
    --preview "$0 --preview {1}" \
    --bind "ctrl-d:execute-silent($0 --delete {1} {2})+reload($0 --list)" \
    --bind "ctrl-x:execute-silent($0 --clear)+reload($0 --list)" \
    --bind "ctrl-n:execute-silent(dwl-dnd)+transform-header($0 --header)"
) || exit 0

IFS=$'\t' read -r id state _ <<<"$sel"
if [ "$state" = open ]; then
  makoctl invoke -n "$id" default || true
  makoctl dismiss -n "$id" || true
fi
