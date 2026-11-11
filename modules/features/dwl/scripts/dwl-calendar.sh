# dwl-calendar
#
# Three-month calendar in a centred kitty popup (Super+K, or clicking the
# bar's clock), standing in for Noctalia's calendar panel. Left/Right
# (Colemak n/i) step a month, Up/Down (u/e) a year, t returns to today,
# q or Escape closes.

month=$(date +%-m)
year=$(date +%Y)

# Hide the cursor while the popup is up.
printf '\e[?25l'
trap 'printf "\e[?25h"' EXIT

while :; do
  printf '\e[H\e[2J'
  cal --color=always -3 "$month" "$year"
  printf '\n \e[2m←/→ month  ↑/↓ year  t today  q close\e[0m'

  IFS= read -rsn1 key || exit 0
  if [ "$key" = $'\e' ]; then
    # An arrow key arrives as ESC [ A..D; a lone ESC is the Escape key.
    IFS= read -rsn2 -t 0.05 rest || exit 0
    key=$rest
  fi
  case $key in
    '[D' | n) month=$((month - 1)) ;;
    '[C' | i) month=$((month + 1)) ;;
    '[A' | u) year=$((year - 1)) ;;
    '[B' | e) year=$((year + 1)) ;;
    t)
      month=$(date +%-m)
      year=$(date +%Y)
      ;;
    q) exit 0 ;;
  esac
  if [ "$month" -lt 1 ]; then
    month=12
    year=$((year - 1))
  elif [ "$month" -gt 12 ]; then
    month=1
    year=$((year + 1))
  fi
done
