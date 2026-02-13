# home/modules/tmux/20-status-and-titles.nix

{ lib, ... }:

{
  programs.tmux.extraConfig = lib.mkAfter ''
    ##### Status + titles #####

    set -g status-left " ❐ #S "
    set -g status-right " #{?client_prefix,⌨ ,}#{?mouse,↗ ,}#{?synchronize-panes,⚏ ,}| #h "

    set -g set-titles on
    set -g set-titles-string "#h ❐ #S ● #I #W"

    set -g clock-mode-style 24
  '';
}

