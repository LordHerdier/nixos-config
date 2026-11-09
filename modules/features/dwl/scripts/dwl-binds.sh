# dwl-binds
#
# Keybind cheat sheet in a centred st-wl popup (Super+H in pkgs/dwl/config.h).
# DWL_BINDS_LIST is the "combo<TAB>action" file scripts.nix generates from
# config.h's key table, so it always matches the running build. Type to
# filter; there is nothing to select, Esc or Super+H again closes it.

fzf \
  --delimiter '\t' --tabstop 28 \
  --layout reverse --no-sort --prompt 'bind> ' \
  --header 'type to filter · esc closes' \
  <"$DWL_BINDS_LIST" >/dev/null || true
