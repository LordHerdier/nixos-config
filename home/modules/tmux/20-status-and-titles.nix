# home/modules/tmux/20-status-and-titles.nix

{ config, lib, ... }:

let
  theme = config.my.theme.active;

  # vim-tpipeline's bridge files, written by neovim and read back here.
  # See ../nvf/plugins/96-tpipeline.nix.
  #
  # The backslash count is load-bearing and survives two unescaping
  # passes: Nix turns `\\\\` into `\\`, then tmux's config parser turns
  # that into a single `\` in the stored option. That surviving
  # backslash is what defers `#{session_id}` into the #() job, where
  # tmux expands it against the pane's own session. Without it the
  # outer format pass substitutes session_id's literal text ("$0")
  # straight into the shell command, and the shell then resolves $0 to
  # its own name -- so `cat` reads a path that does not exist and the
  # statusline silently renders empty.
  vimbridge = "#(cat #{socket_path}-\\\\#{session_id}-vimbridge)";
  vimbridgeR = "#(cat #{socket_path}-\\\\#{session_id}-vimbridge-R)";
in
{
  programs.tmux.extraConfig = lib.mkAfter ''
    ##### Status + titles #####

    set -g status-interval 2

    # Both halves hold a neovim statusline when a neovim pane has focus,
    # and collapse to nothing when one does not, so the lengths have to
    # leave room for a full lualine rather than just the static chunks.
    # The trailing `#[default]` on each is load-bearing: lualine signs
    # off on `bg=terminal`, which would otherwise bleed out of the
    # statusline and across whatever tmux draws next.
    #
    # The hostname is deliberately absent: it costs width that the
    # neovim half needs, and set-titles-string below already puts #h in
    # the terminal's title bar.
    #
    # status-right runs tmux's own chunks first and ends with neovim's.
    # That ordering also protects the editor half: tmux trims the *left*
    # edge of status-right when the bar will not fit, so a long track
    # title is eaten before the branch and line:col are, rather than the
    # other way round. Verified at 90 columns, where now-playing loses
    # its first few characters and neovim's half stays whole.
    set -g status-left "#[fg=${theme.roles.surface},bg=${theme.palette.yellow},bold] ❐ #S #[default]${vimbridge}#[default]"
    set -g status-left-length 200
    set -g status-right " #[range=user|nowplaying,fg=${theme.palette.magenta}]#(~/.config/tmux/scripts/now-playing.sh)#[norange,default] #{?client_prefix,⌨ ,}#{?mouse,↗ ,}#{?synchronize-panes,⚏ ,}| #{session_dots} | ${vimbridgeR}#[default]"
    set -g status-right-length 200

    set -g set-titles on
    set -g set-titles-string "#h ❐ #S ● #I #W"

    set -g clock-mode-style 24
  '';
}
