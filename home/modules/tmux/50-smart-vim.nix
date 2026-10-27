# home/modules/tmux/50-smart-vim.nix

{ lib, ... }:

{
  programs.tmux.extraConfig = lib.mkAfter ''
    ##### Smart pane switching (no bc required) #####

    is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf|lazygit)(diff)?$'"

    bind-key -n 'C-\' if-shell "$is_vim" 'send-keys C-\\'  'select-pane -l'

    bind-key -T copy-mode-vi 'C-\' select-pane -l

    # Smart scrolling - PageUp/PageDown only when not in vim
    bind-key -n PageUp if-shell "$is_vim" 'send-keys PageUp' 'copy-mode -u'
    bind-key -n PageDown if-shell "$is_vim" 'send-keys PageDown' 'send-keys PageDown'
  '';
}
