# home/modules/nvf/plugins/97-textobjects.nix
#
# Treesitter textobjects: operate on functions, classes and parameters as
# units rather than by line count.
#
# The keymaps are written out by hand rather than handed to nvf's
# `treesitter.textobjects.setupOpts`. That option predates the plugin's
# rewrite: nvf feeds it to `require("nvim-treesitter.config").setup()`,
# whose main-branch implementation is a plain tbl_deep_extend over
# `{ install_dir }` -- the `textobjects` key is swallowed without error and
# no mapping is ever created. Enabling the option is still worthwhile, as
# that is what puts the plugin on the runtimepath.
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
          -- Jump forward to the next match when the cursor is not already
          -- inside one, so `cif` works from the blank line above a function.
          lookahead = true,
        },
        move = { set_jumps = true },
      })

      local select = require("nvim-treesitter-textobjects.select")
      local move = require("nvim-treesitter-textobjects.move")

      -- Note: ../90-keymaps.nix maps `i` to `l` in visual and
      -- operator-pending modes, which shadows bare inner-textobjects such as
      -- `ciw`. These mappings are longer than that one key, so vim's
      -- longest-match rule still resolves them correctly.
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
