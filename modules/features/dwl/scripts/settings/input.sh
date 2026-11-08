# Input page: the keyboard layout, and a shortcut to the keybind cheat sheet.
# Concatenated into dwl-settings by scripts.nix; relies on common.sh.
#
# dwl (89-xkb-layout) writes the active layout's name to dwl-xkb-layout and
# every layout's name, one per line in index order, to dwl-xkb-layouts. A
# choice is made by writing its index to dwl-xkb-set and signalling dwl
# (dwl-xkb-switch), which 99-xkb-layout-signal reads. Natural scroll and key
# repeat are compile-time in pkgs/dwl/config.h, so they are not here.

xkb_dir=${XDG_RUNTIME_DIR:?}

xkb_active() {
  local name=''
  read -r name <"$xkb_dir/dwl-xkb-layout" || true
  echo "${name:-unknown}"
}

input_summary() { xkb_active; }

keyboard_menu() {
  local active i name sel idx
  if ! [ -r "$xkb_dir/dwl-xkb-layouts" ]; then
    notice "dwl hasn't written its layout list (a dwl from before this patch is running; log out and back in)."
    return 0
  fi
  while :; do
    active=$(xkb_active)
    sel=$(
      i=0
      while read -r name; do
        if [ "$name" = "$active" ]; then
          printf '* %s\t%s\n' "$name" "$i"
        else
          printf '  %s\t%s\n' "$name" "$i"
        fi
        i=$((i + 1))
      done <"$xkb_dir/dwl-xkb-layouts" | pick layout
    ) || return 0
    idx=${sel#*$'\t'}
    echo "$idx" >"$xkb_dir/dwl-xkb-set"
    dwl-xkb-switch
    # dwl rewrites dwl-xkb-layout once it has switched.
    sleep 0.2
  done
}

input_menu() {
  local sel
  while :; do
    sel=$(
      {
        printf 'Keyboard layout  %s\tlayout\n' "$(xkb_active)"
        printf 'Keybind cheat sheet\tbinds\n'
      } | pick input
    ) || return 0
    case ${sel#*$'\t'} in
      layout) keyboard_menu ;;
      binds) dwl-modal binds; exit 0 ;;
      *) ;;
    esac
  done
}
