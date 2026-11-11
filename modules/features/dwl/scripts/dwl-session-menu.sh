# dwl-session-menu
#
# Power / session menu in a centred kitty popup (Super+O), standing in for
# Noctalia's session panel: same entries, order and 1-7 shortcuts as
# `session.actions` in home/modules/noctalia.nix, and the same 10 s
# countdown (Enter skips it, any other key cancels).

# label<TAB>command; the shortcut is the line number. Lock is qylock, as on
# Super+L (hypridle's lock_cmd is Hyprland's hyprlock). Logout SIGTERMs dwl,
# which quits as Super+Shift+L does.
entries=(
  $'Lock\tqylock-lock'
  $'Suspend\tsystemctl suspend'
  $'Hibernate\tsystemctl hibernate'
  $'Reboot\tsystemctl reboot'
  $'Logout\tpkill -TERM -u '"$(id -u)"' -x dwl'
  $'Shutdown\tsystemctl poweroff'
  $'Reboot to UEFI\tsystemctl reboot --firmware-setup'
)

binds=()
for i in "${!entries[@]}"; do
  binds+=(--bind "$((i + 1)):pos($((i + 1)))+accept")
done

sel=$(
  for i in "${!entries[@]}"; do
    printf '%d  %s\n' "$((i + 1))" "${entries[i]}"
  done | fzf \
    --delimiter '\t' --with-nth 1 \
    --layout reverse --no-sort --prompt 'session> ' \
    --header '1-7 or enter: pick · esc: close' \
    "${binds[@]}"
) || exit 0

label=${sel%%$'\t'*}
label=${label#*  }
cmd=${sel#*$'\t'}

for ((n = 10; n > 0; n--)); do
  printf '\r\e[K%s in %d s · enter: now · any other key: cancel' "$label" "$n"
  if read -rsn1 -t 1 key; then
    [ -z "$key" ] && break
    exit 0
  fi
done
printf '\n'

# Detached, for the reason given at the end of dwl-clipboard: the popup only
# closes once nothing holds its pty, and these should outlive it anyway.
# shellcheck disable=SC2086 # cmd is a fixed word list from entries above
setsid -f $cmd >/dev/null 2>&1
