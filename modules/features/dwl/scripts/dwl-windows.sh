# dwl-windows
#
# fzf window switcher, run in a centred st-wl popup (Super+Alt+Tab in
# pkgs/dwl/config.h), standing in for Noctalia's window switcher. Enter goes
# to the window: dwl switches its monitor to the window's tags and focuses it
# (85-foreign-toplevel-management.patch); Ctrl+D closes it. Super+Tab is the
# Alt+Tab-style recent-window cycle in dwl itself (87-alt-tab.patch).
#
# wlrctl matches windows by exact app_id and title, and the protocol has no
# stable IDs, so two windows with the same app_id and title can't be told
# apart: the first one wins.

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
