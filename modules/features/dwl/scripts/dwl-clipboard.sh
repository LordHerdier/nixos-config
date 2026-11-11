# dwl-clipboard
#
# fzf menu over the cliphist history (filled by dwl-startup's watchers) in a
# centred kitty popup (Super+V), standing in for Noctalia's clipboard panel.
# Enter copies the entry back; Ctrl+D deletes it. Images are previewed with
# kitty icat.

# Internal: called by fzf's preview below with the highlighted line.
if [ "${1:-}" = --preview ]; then
  entry=$2
  if [[ $entry == *"[[ binary data "* ]]; then
    printf '%s\n' "$entry" | cliphist decode | kitty icat --clear --transfer-mode=memory --unicode-placeholder --stdin=yes \
      --place="${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}@0x0"
  else
    printf '%s\n' "$entry" | cliphist decode
  fi
  exit 0
fi

sel=$(
  cliphist list | fzf \
    --delimiter '\t' --with-nth 2.. \
    --layout reverse --prompt 'clipboard> ' \
    --header 'enter: copy · ctrl-d: delete' \
    --preview-window right,55%,border-left,wrap \
    --preview "$0 --preview {}" \
    --bind 'ctrl-d:execute-silent(printf "%s\n" {} | cliphist delete)+reload(cliphist list)'
) || exit 0

# wl-copy stays behind to serve the clipboard. setsid keeps it clear of the
# SIGHUP when this script (the popup's session leader) exits, and the
# redirect stops it holding the pty: kitty only closes the popup once nothing
# has the terminal open, not when this script exits.
printf '%s\n' "$sel" | cliphist decode | setsid -f wl-copy >/dev/null 2>&1
