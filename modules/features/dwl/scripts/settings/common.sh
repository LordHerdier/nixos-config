# Shared by every settings page; concatenated ahead of them (scripts.nix).

# label<TAB>payload lines on stdin; prints the chosen line. Arguments after
# the prompt go to fzf (a page's --preview).
pick() {
  local prompt=$1
  shift
  fzf --delimiter '\t' --with-nth 1 --layout reverse --no-sort \
    --prompt "$prompt> " --header 'enter: pick · esc: back' "$@"
}

pause() {
  printf '\nfailed · press any key'
  read -rsn1 || true
}

# Shows a few lines of read-only information until a key is pressed.
notice() {
  printf '%s\n\npress any key' "$1"
  read -rsn1 || true
}

# "on" or "off" for a function that succeeds when the thing is on.
onoff() {
  if "$1"; then echo on; else echo off; fi
}
