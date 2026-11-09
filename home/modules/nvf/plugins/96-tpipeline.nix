# home/modules/nvf/plugins/96-tpipeline.nix
#
# vim-tpipeline moves lualine into the tmux status line, so a neovim pane
# shows one bar instead of two. neovim renders into a pair of files next
# to the tmux socket ("$TMUX_SOCKET-$<session id>-vimbridge" and "...-R")
# and tmux `#(cat …)`s them back; the tmux side is in
# ../../tmux/20-status-and-titles.nix -- change both together.
#
# Outside tmux the plugin does nothing and neovim keeps its own
# statusline.

{ pkgs, ... }:

{
  config.vim.extraPlugins.vim-tpipeline = {
    package = pkgs.vimPlugins.vim-tpipeline;
  };

  config.vim.globals = {
    # Don't let the plugin rewrite status-left/right: the tmux module
    # already embeds the bridge files around its own chunks.
    tpipeline_autoembed = 0;

    # lualine left+middle -> status-left, right -> status-right.
    tpipeline_split = 1;

    # Redraw on CursorMoved so the line/column segment is not stale.
    tpipeline_cursormoved = 1;
  };

  # Publishes @nvim_active so tmux shrinks its window list to bare numbers
  # while a focused neovim occupies the bar (../../tmux/30-colors.nix).
  # Focus-based, not a `ps` probe like ../../tmux/50-smart-vim.nix: only
  # the focused neovim feeds the bridge files.
  config.vim.luaConfigRC.tpipeline-window-flag = # lua
    ''
      if vim.env.TMUX then
        local group = vim.api.nvim_create_augroup("TpipelineWindowFlag", { clear = true })

        local function flag(value)
          -- Session scoped; fire-and-forget so tmux can't block neovim.
          pcall(vim.system, { "tmux", "set-option", "@nvim_active", value })
        end

        -- A neovim that starts unfocused never gets FocusLost, so it would
        -- keep writing its statusline into the session's bridge file over
        -- the focused one. Park it until it gains focus.
        local parked = false

        -- Use state#restore/state#reload, not freeze/thaw: restore kills
        -- the writer job and only reload forks a fresh one.
        local function park()
          parked = true
          pcall(vim.fn["tpipeline#state#restore"])
          -- restore() resets laststatus=2; keep ../00-options.nix's 3.
          vim.opt.laststatus = 3
        end

        local function unpark()
          if not parked then
            return
          end
          parked = false
          pcall(vim.fn["tpipeline#state#reload"])
        end

        -- tmux-resurrect starts several neovims at once, at most one of
        -- them frontmost.
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
              -- Fast event context: vim.fn needs the main loop.
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

        -- FocusGained only fires on a focus *change*, so a neovim started
        -- in the focused pane never sees one; hence VimEnter.
        vim.api.nvim_create_autocmd("VimEnter", { group = group, callback = on_enter })

        vim.api.nvim_create_autocmd("FocusGained", {
          group = group,
          callback = function()
            unpark()
            flag("1")
          end,
        })

        -- FocusLost needs tmux `focus-events on`; VimLeavePre covers quit.
        vim.api.nvim_create_autocmd({ "FocusLost", "VimLeavePre" }, {
          group = group,
          callback = function() flag("0") end,
        })
      end
    '';
}
