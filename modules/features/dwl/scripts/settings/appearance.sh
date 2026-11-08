# Appearance page: the colour palette and the wallpaper. Concatenated into
# dwl-settings by scripts.nix; relies on common.sh.
#
# Palettes go through `theme-set`, which recolours every my.theme app (mako,
# st-wl, ...) and hands dwl its palette; bare dwl-theme would only recolour
# dwl and the bar. theme-set comes from the user's Home Manager profile, so
# it is looked up on PATH rather than being a runtime input.

have_theme_set() { command -v theme-set >/dev/null; }

# The palette name without theme-set's " (default)" suffix.
current_palette() {
  local cur
  cur=$(theme-set current)
  echo "${cur% (default)}"
}

appearance_summary() {
  if have_theme_set; then current_palette; else echo "theme-set not found"; fi
}

# Colour blocks for a palette's colours file, for the palette picker's
# preview. "default" is whatever the last rebuild set.
swatch() {
  local file=${DWL_THEMES:?}/$1
  if [ "$1" = default ]; then file=/etc/dwl/colors; fi
  [ -r "$file" ] || return 0
  awk -F= '
    /^[a-z_]+=#[0-9a-fA-F]+$/ {
      c = substr($2, 2)
      printf "\033[48;2;%d;%d;%dm      \033[0m %-16s %s\n", \
        strtonum("0x" substr(c, 1, 2)), strtonum("0x" substr(c, 3, 2)), \
        strtonum("0x" substr(c, 5, 2)), $1, $2
    }' "$file"
}

palette_menu() {
  local cur sel name
  while :; do
    cur=$(current_palette)
    sel=$(
      {
        theme-set list | while read -r name; do
          if [ "$name" = "$cur" ]; then
            printf '* %s\t%s\n' "$name" "$name"
          else
            printf '  %s\t%s\n' "$name" "$name"
          fi
        done
        printf '  back to the built default\tdefault\n'
      } | pick palette --preview 'dwl-settings --swatch {2}' --preview-window right,45%
    ) || return 0
    name=${sel#*$'\t'}
    theme-set "$name" || pause
  done
}

appearance_menu() {
  local sel
  if ! have_theme_set; then
    notice "theme-set isn't on PATH (it comes from the Home Manager profile)."
    return 0
  fi
  while :; do
    sel=$(
      {
        printf 'Palette    %s\tpalette\n' "$(current_palette)"
        printf 'Wallpaper (with previews)\twallpaper\n'
      } | pick appearance
    ) || return 0
    case ${sel#*$'\t'} in
      palette) palette_menu ;;
      wallpaper) dwl-modal wallpaper; exit 0 ;;
      *) ;;
    esac
  done
}
