# Shared by every settings page; concatenated ahead of them (scripts.nix).

# label<TAB>payload lines on stdin; prints the chosen line.
pick() {
  fzf --delimiter '\t' --with-nth 1 --layout reverse --no-sort \
    --prompt "$1> " --header 'enter: pick · esc: back'
}

pause() {
  printf '\nfailed · press any key'
  read -rsn1 || true
}
