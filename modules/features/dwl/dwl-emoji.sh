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

# Fed by process substitution so only fzf's status counts: awk can die of
# SIGPIPE if fzf exits first, which pipefail would take as cancelling.
sel=$(
  fzf \
    --delimiter '\t' --nth 2 \
    --layout reverse --prompt 'emoji> ' \
    --header 'enter: copy' \
    < <(awk '!seen[$0]++' "$recent" "$list")
) || exit 0

# Detached, for the reason given at the end of dwl-clipboard.
printf '%s' "${sel%%$'\t'*}" | setsid -f wl-copy >/dev/null 2>&1

# grep exits 1 when it keeps no lines (an empty list, or only this pick),
# which pipefail would otherwise turn into the script failing here.
{
  printf '%s\n' "$sel"
  { grep -vxF -- "$sel" "$recent" || true; } | head -n 29
} >"$recent.new"
mv "$recent.new" "$recent"
