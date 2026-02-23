# home/modules/tmux/10-keybinds.nix

{ lib, ... }:

{
  programs.tmux.extraConfig = lib.mkAfter ''
    ##### Keybinds #####

    # Vim-style pane navigation
    bind-key h select-pane -L
    bind-key j select-pane -D
    bind-key k select-pane -U
    bind-key l select-pane -R

    # Window navigation
    bind-key Tab next-window
    bind-key BTab previous-window

    # New window/pane in current directory
    bind c new-window -c "#{pane_current_path}"
    bind - split-window -v -c "#{pane_current_path}"
    bind _ split-window -h -c "#{pane_current_path}"

    # Copy mode (vi)
    bind-key -T copy-mode-vi 'v' send-keys -X begin-selection
    bind-key -T copy-mode-vi 'y' send-keys -X copy-selection-and-cancel

    # Give me C-P back please
    unbind -T copy-mode C-p
  '';
}
