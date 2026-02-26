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
    bind-key BTab previous-window

    # New window/pane in current directory
    bind c new-window -c "#{pane_current_path}"
    bind v split-window -v -c "#{pane_current_path}"
    bind h split-window -h -c "#{pane_current_path}"

    # Session Switching
    bind-key ] switch-client -n
    bind-key [ switch-client -p

    # Copy mode (vi)
    bind-key -T copy-mode-vi 'v' send-keys -X begin-selection
    bind-key -T copy-mode-vi 'y' send-keys -X copy-selection-and-cancel
  '';
}
