# dwl-emoji
#
# Emoji picker in a centred kitty popup (Super+. in pkgs/dwl/config.h),
# standing in for Noctalia's "/emo" launcher. DWL_EMOJI_LIST is the
# "emoji<TAB>name" file dwl.nix builds from Unicode's emoji-test.txt. Enter copies the emoji to
# the clipboard; the last 30 picks are listed first.

list=$DWL_EMOJI_LIST
recent=${XDG_STATE_HOME:-$HOME/.local/state}/dwl-emoji/recent
mkdir -p "${recent%/*}"
touch "$recent"

sel=$(
  cat "$recent" "$list" | awk '!seen[$0]++' | fzf \
    --delimiter '\t' --nth 2 \
    --layout reverse --prompt 'emoji> ' \
    --header 'enter: copy'
) || exit 0

{
  printf '%s\n' "$sel"
  grep -vxF -- "$sel" "$recent" | head -n 29
} >"$recent.new"
mv "$recent.new" "$recent"

# Detached, for the reason given at the end of dwl-clipboard.
printf '%s' "${sel%%$'\t'*}" | setsid -f wl-copy >/dev/null 2>&1
