# home/modules/tmux/10-keybinds.nix

{ lib, ... }:

{
  programs.tmux.extraConfig = lib.mkAfter ''
    ##### Keybinds #####

    # Vim-style pane navigation (colemak)
    bind-key C-n select-pane -L
    bind-key C-e select-pane -D 
    bind-key C-u select-pane -U
    bind-key C-i select-pane -R

    # Window navigation
    bind-key Tab next-window
    bind-key "S-Tab" previous-window

    # New window/pane in current directory
    bind c new-window -c "#{pane_current_path}"
    bind v split-window -v -c "#{pane_current_path}"
    bind h split-window -h -c "#{pane_current_path}"

    # zoom
    bind-key z resize-pane -Z

    # Session Switching
    bind-key ] switch-client -n
    bind-key [ switch-client -p

    # Make tmux try to talk to the system clipboard
    set -g set-clipboard on

    # In copy-mode-vi, make 'y' copy + pipe out
    bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel \
      'command -v wl-copy >/dev/null && wl-copy || command -v xclip >/dev/null && xclip -in -selection clipboard || command -v pbcopy >/dev/null && pbcopy || command -v clip.exe >/dev/null && clip.exe'

  '';
}
