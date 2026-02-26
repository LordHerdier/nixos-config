# home/modules/tmux/00-core.nix

{ lib, ... }:

{
  programs.tmux.extraConfig = lib.mkAfter ''
    ##### Core behavior #####

    # Reload config
    unbind r
    bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded!"

    # Terminal settings
    set -ag terminal-overrides ",xterm-256color:RGB"
    set -as terminal-overrides ',*:smcup@:rmcup@'

    # Prefix (bind to space)
    unbind C-b
    set -g prefix C-Space
    bind C-Space send-prefix

    # Mouse + vi keys
    set -g mouse on
    set -g allow-passthrough off
    set-window-option -g mode-keys vi
    set -g status-keys vi

    # Status bar position
    set-option -g status-position bottom

    # Faster escape
    set -sg escape-time 10

    # History
    set -g history-limit 10000

    # Start at 1
    set -g base-index 1
    setw -g pane-base-index 1

    # Renumber windows
    set -g renumber-windows on

    # Disable auto-renaming
    set -g allow-rename off
    setw -g automatic-rename off

    ##### Plugin settings #####
    # tmux-resurrect
    set -g @resurrect-strategy-vim 'session'
    set -g @resurrect-strategy-nvim 'session'
    set -g @resurrect-capture-pane-contents 'on'

    # tmux-continuum
    set -g @continuum-save-interval '10'
    set -g @continuum-restore 'on'
  '';
}
