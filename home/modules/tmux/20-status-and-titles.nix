# home/modules/tmux/20-status-and-titles.nix

{ lib, ... }:

let
  # vim-tpipeline's bridge files, written by neovim and read back here.
  # See ../nvf/plugins/96-tpipeline.nix.
  #
  # The backslash count is load-bearing: Nix turns `\\\\` into `\\`, tmux's
  # parser into one `\`, which defers `#{session_id}` into the #() job.
  # Without it the outer pass substitutes "$0" into the shell command,
  # the shell expands that to its own name, and the statusline silently
  # renders empty.
  vimbridge = "#(cat #{socket_path}-\\\\#{session_id}-vimbridge)";
  vimbridgeR = "#(cat #{socket_path}-\\\\#{session_id}-vimbridge-R)";
in
{
  programs.tmux.extraConfig = lib.mkAfter ''
    ##### Status + titles #####

    set -g status-interval 2

    # Both halves embed a neovim statusline when a neovim pane has focus,
    # so the lengths leave room for a full lualine. The trailing
    # `#[default]` is load-bearing: lualine ends on `bg=terminal`, which
    # would otherwise bleed into whatever tmux draws next.
    #
    # No hostname: the neovim half needs the width, and set-titles-string
    # already puts #h in the title bar.
    #
    # neovim's chunk goes last in status-right because tmux trims the
    # *left* edge when it doesn't fit, so now-playing is eaten first.
    set -g status-left "#[fg=#{@tm_surface},bg=#{@tm_attention},bold] ❐ #S #[default]${vimbridge}#[default]"
    set -g status-left-length 200
    set -g status-right " #[range=user|nowplaying,fg=#{@tm_magenta}]#(~/.config/tmux/scripts/now-playing.sh)#[norange,default] #{?client_prefix,⌨ ,}#{?mouse,↗ ,}#{?synchronize-panes,⚏ ,}| #[fg=#{@session-dots-color}]#(~/.config/tmux/scripts/session-dots.sh '#S')#[default] | ${vimbridgeR}#[default]"
    set -g status-right-length 200

    set -g set-titles on
    set -g set-titles-string "#h ❐ #S ● #I #W"

    set -g clock-mode-style 24
  '';
}
