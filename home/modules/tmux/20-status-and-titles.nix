{ lib, ... }:

{
  programs.tmux.extraConfig = lib.mkAfter ''
    ##### Status + titles #####

    set -g status-interval 2

    set -g status-left " ❐ #S "
    set -g status-right "#[range=user|nowplaying,fg=#D27E99]#(~/.config/tmux/scripts/now-playing.sh)#[norange,default] #{?client_prefix,⌨ ,}#{?mouse,↗ ,}#{?synchronize-panes,⚏ ,}| #{session_dots} | #h "
    set -g status-right-length 80

    set -g set-titles on
    set -g set-titles-string "#h ❐ #S ● #I #W"

    set -g clock-mode-style 24
  '';
}
