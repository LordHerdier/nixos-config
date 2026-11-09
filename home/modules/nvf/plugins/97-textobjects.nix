# home/modules/nvf/plugins/97-textobjects.nix
#
# Treesitter textobjects: functions, classes, parameters and loops.
#
# Keymaps are set by hand: nvf feeds `treesitter.textobjects.setupOpts` to
# nvim-treesitter's main-branch config.setup(), which silently ignores the
# `textobjects` key. `enable` is still needed to put the plugin on the
# runtimepath.
#
# Movement keys avoid [c/]c (gitsigns hunks) and [x/]x (git-conflict).

{ ... }:

{
  config.vim.treesitter.textobjects.enable = true;

  config.vim.luaConfigRC.treesitter-textobjects = # lua
    ''
      local ok, textobjects = pcall(require, "nvim-treesitter-textobjects")
      if not ok then
        return
      end

      textobjects.setup({
        select = {
          -- Jump ahead to the next match, so `cif` works from above.
          lookahead = true,
        },
        move = { set_jumps = true },
      })

      local select = require("nvim-treesitter-textobjects.select")
      local move = require("nvim-treesitter-textobjects.move")

      -- ../90-keymaps.nix maps `i` to `l` in visual mode; these longer
      -- mappings still win by longest match, so `vif` works there.
      local objects = {
        f = "@function",
        c = "@class",
        a = "@parameter",
        o = "@loop",
      }

      for key, query in pairs(objects) do
        for prefix, part in pairs({ a = ".outer", i = ".inner" }) do
          vim.keymap.set({ "x", "o" }, prefix .. key, function()
            select.select_textobject(query .. part, "textobjects")
          end, { desc = "Select " .. prefix .. key .. " " .. query .. part })
        end
      end

      local moves = {
        f = "@function.outer",
        t = "@class.outer",
        a = "@parameter.inner",
      }

      for key, query in pairs(moves) do
        vim.keymap.set({ "n", "x", "o" }, "]" .. key, function()
          move.goto_next_start({ query }, "textobjects")
        end, { desc = "Next " .. query })

        vim.keymap.set({ "n", "x", "o" }, "[" .. key, function()
          move.goto_previous_start({ query }, "textobjects")
        end, { desc = "Previous " .. query })
      end
    '';
}
