# home/modules/tmux/40-url-helpers.nix

{ lib, ... }:

{
  programs.tmux.extraConfig = lib.mkAfter ''
    ##### URL helpers (WSL-friendly) #####

    # Open URL via wslview if available, else xdg-open
    bind-key u capture-pane \; save-buffer /tmp/tmux-buffer \; new-window -n urls \
      '$SHELL -lc "url=$(grep -oE \"https?://[a-zA-Z0-9./?=_%:-]*\" /tmp/tmux-buffer | sort -u | fzf --prompt=\"Open URL: \" ) && \
      { command -v wslview >/dev/null && wslview \"$url\" || command -v xdg-open >/dev/null && xdg-open \"$url\"; }"'

    # Copy first URL to Windows clipboard
    bind-key C-u capture-pane \; save-buffer /tmp/tmux-buffer \; run-shell \
      'grep -oE "https?://[a-zA-Z0-9./?=_%:-]*" /tmp/tmux-buffer | head -1 | tr -d "\n" | clip.exe' \; \
      display-message "URL copied to clipboard"

    # Edit configuration quickly
    bind e new-window -n "tmux.conf" "nvim ~/.config/tmux/tmux.conf && tmux source-file ~/.config/tmux/tmux.conf && tmux display-message 'Config reloaded!'"
  '';
}

