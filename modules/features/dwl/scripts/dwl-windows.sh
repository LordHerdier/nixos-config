# dwl-windows
#
# fzf window switcher in a centred kitty popup (Super+Alt+Tab), standing in
# for Noctalia's. Enter goes to the window (dwl views its tags and focuses
# it, 42-foreign-toplevel-management.patch); Ctrl+D closes it.
#
# wlrctl matches by exact app_id and title (the protocol has no stable IDs),
# so of two windows with the same pair, the first one wins.

# `wlrctl toplevel list` prints "app_id: title". Skip the popups themselves
# (app_id "modal", see dwl-modal).
list() {
  wlrctl toplevel list | grep -v '^modal: ' || true
}

# Internal: called by fzf's ctrl-d bind below with the highlighted line.
if [ "${1:-}" = --close ]; then
  wlrctl toplevel close app_id:"${2%%: *}" title:"${2#*: }"
  exit 0
fi
if [ "${1:-}" = --list ]; then
  list
  exit 0
fi

sel=$(
  list | fzf \
    --layout reverse --prompt 'windows> ' \
    --header 'enter: go to · ctrl-d: close' \
    --bind "ctrl-d:execute-silent($0 --close {})+reload(sleep 0.2; $0 --list)"
) || exit 0

wlrctl toplevel focus app_id:"${sel%%: *}" title:"${sel#*: }"
