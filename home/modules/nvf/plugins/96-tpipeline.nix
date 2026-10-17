# home/modules/nvf/plugins/96-tpipeline.nix
#
# vim-tpipeline moves the lualine bar out of neovim and into the tmux
# status line, so a neovim pane inside tmux shows one bar instead of two
# stacked ones. The mechanism is a pair of files next to the tmux socket
# ("$TMUX_SOCKET-$<session id>-vimbridge" and "...-R"); neovim renders
# lualine into them and tmux `#(cat …)`s them back out. The tmux side of
# that handshake lives in ../../tmux/20-status-and-titles.nix -- editing
# one without the other leaves either a blank bar or a doubled one.
#
# The plugin finishes nothing on its own: plugin/tpipeline.vim bails out
# unless $TMUX is set, so neovim outside tmux keeps its own statusline
# (laststatus from ../00-options.nix) untouched.

{ pkgs, ... }:

{
  config.vim.extraPlugins.vim-tpipeline = {
    package = pkgs.vimPlugins.vim-tpipeline;
  };

  config.vim.globals = {
    # Do not let the plugin rewrite status-left/status-right behind our
    # back on startup. The tmux module already embeds the bridge files,
    # which is what keeps the session indicator and the now-playing /
    # session-dots chunks from being clobbered.
    tpipeline_autoembed = 0;

    # Send lualine's left+middle sections to status-left and its right
    # section to status-right, matching how the two bars already line up.
    tpipeline_split = 1;

    # Redraw on CursorMoved so the line/column segment is not stale.
    tpipeline_cursormoved = 1;
  };

  # The statusline above is wide, and it shares the bar with the tmux
  # window list. Publishing a focus flag onto the session lets tmux
  # shrink that list to bare window numbers for exactly as long as a
  # neovim is actually occupying the bar -- see ../../tmux/30-colors.nix,
  # which reads @nvim_active.
  #
  # This is deliberately not a `ps`-based probe like the one in
  # ../../tmux/50-smart-vim.nix: that answers "is a pane running vim",
  # whereas the bar only loses room to the one neovim that currently has
  # focus, which is the same neovim that is feeding the bridge files.
  config.vim.luaConfigRC.tpipeline-window-flag = # lua
    ''
      if vim.env.TMUX then
        local group = vim.api.nvim_create_augroup("TpipelineWindowFlag", { clear = true })

        local function flag(value)
          -- Session scoped, so every window's status format sees it. Fired
          -- and forgotten: a failing tmux here must never block neovim.
          pcall(vim.system, { "tmux", "set-option", "@nvim_active", value })
        end

        -- A neovim that comes up without focus must not touch the bar at
        -- all: tpipeline writes into one bridge file per tmux session, and
        -- it only stops writing when it is told it lost focus. An instance
        -- that never had focus is never told, so it would sit there
        -- broadcasting its own statusline over whatever the user is
        -- actually looking at. Freezing it parks it until it is focused.
        local parked = false

        -- state#restore and state#reload are the matched pair. The
        -- freeze/thaw pair is not: restoring stops the background writer
        -- job outright (tpipeline#cleanup calls jobstop), and only
        -- reload runs the initialize path that forks a fresh one, so a
        -- thawed instance would come back with its hooks live and
        -- nothing left to write through.
        local function park()
          parked = true
          pcall(vim.fn["tpipeline#state#restore"])
          -- restore() drops back to laststatus=2; keep the global bar
          -- this config asks for in ../00-options.nix while parked.
          vim.opt.laststatus = 3
        end

        local function unpark()
          if not parked then
            return
          end
          parked = false
          pcall(vim.fn["tpipeline#state#reload"])
        end

        -- tmux-resurrect restores whole sessions at once (see
        -- ../../tmux/00-core.nix), so several neovims reach VimEnter
        -- together while at most one of them is frontmost.
        local function on_enter()
          local pane = vim.env.TMUX_PANE
          if not pane then
            return
          end
          pcall(
            vim.system,
            { "tmux", "display-message", "-p", "-t", pane, "#{&&:#{pane_active},#{window_active}}" },
            { text = true },
            function(out)
              -- Back to the main loop: this lands in a fast event context,
              -- where vim.fn is off limits.
              vim.schedule(function()
                if out.code == 0 and vim.trim(out.stdout) == "1" then
                  flag("1")
                else
                  park()
                end
              end)
            end
          )
        end

        -- FocusGained only arrives on a *change* of focus, so a neovim
        -- started in the pane that already had focus never sees one --
        -- hence VimEnter, which is the guarded path.
        vim.api.nvim_create_autocmd("VimEnter", { group = group, callback = on_enter })

        vim.api.nvim_create_autocmd("FocusGained", {
          group = group,
          callback = function()
            unpark()
            flag("1")
          end,
        })

        -- FocusLost needs `focus-events on`; VimLeavePre is the backstop
        -- for the quit path, where no focus change is ever reported.
        vim.api.nvim_create_autocmd({ "FocusLost", "VimLeavePre" }, {
          group = group,
          callback = function() flag("0") end,
        })
      end
    '';
}
