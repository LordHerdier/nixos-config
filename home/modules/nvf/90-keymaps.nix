# home/modules/nvf/90-keymaps.nix

# Note: format-on-save mangles this file; save with `:noautocmd w`.

{ lib, ... }:

let
  # ── Colemak movement ──────────────────────────────────────────────
  # Vertical movement is safe everywhere, operator-pending included:
  # `du` / `de` act linewise and shadow nothing.
  verticalMoves = [
    {
      key = "u";
      action = "k";
      desc = "Move up";
    }
    {
      key = "e";
      action = "j";
      desc = "Move down";
    }
    {
      key = "gu";
      action = "gk";
      desc = "Move up (wrapped)";
    }
    {
      key = "ge";
      action = "gj";
      desc = "Move down (wrapped)";
    }
  ];

  # Horizontal movement skips operator-pending mode: there `i` starts an
  # inner textobject, and `i` -> `l` would turn `ciw` into `cl` + "w".
  # (`dh` / `dl` still delete a character.)
  #
  # Visual mode keeps the mapping so `i` extends a selection rightward,
  # at the cost of `vi(` / `viw` -- use `ci(` or the treesitter
  # textobjects from plugins/97-textobjects.nix instead.
  horizontalMoves = [
    {
      key = "n";
      action = "h";
      desc = "Move left";
    }
    {
      key = "i";
      action = "l";
      desc = "Move right";
    }
  ];

  # "x" (Visual only), never "v": `:vmap` also covers Select mode, where
  # luasnip parks the cursor on a placeholder, and u/e/n/i would move
  # instead of typing over it.
  allModes = [
    "n"
    "x"
    "o"
  ];
  nonOperatorModes = [
    "n"
    "x"
  ];

  withModes = modes: moves: builtins.concatMap (mode: map (m: m // { inherit mode; }) moves) modes;

  movementKeymaps = withModes allModes verticalMoves ++ withModes nonOperatorModes horizontalMoves;
in
{
  config.vim.globals = {
    mapleader = " ";
  };

  config.vim = {
    keymaps = movementKeymaps ++ [
      # vim-repeat lazily maps `u` to <Plug>(RepeatUndo) on first
      # repeat#set unless hasmapto() finds an existing map, clobbering
      # `u` -> `k`. These inert maps make hasmapto() true.
      {
        mode = "n";
        key = "<Plug>(RepeatUndoGuard)";
        action = "<Plug>(RepeatUndo)";
        noremap = false;
        desc = "Keep vim-repeat from remapping u";
      }
      {
        mode = "n";
        key = "<Plug>(RepeatRedoGuard)";
        action = "<Plug>(RepeatRedo)";
        noremap = false;
        desc = "Keep vim-repeat from remapping <C-r>";
      }

      # ==================== Basic ====================
      {
        mode = "n";
        key = ";";
        action = ":";
        desc = "Enter command mode";
      }
      {
        mode = "n";
        key = "Q";
        action = ":q<CR>";
        desc = "Quit";
      }
      {
        mode = "n";
        key = "S";
        action = ":w<CR>";
        desc = "Save";
      }
      {
        mode = "n";
        key = "l";
        action = "u";
        desc = "Undo";
      }
      {
        mode = "n";
        key = "k";
        action = "i";
        desc = "Insert mode";
      }
      {
        mode = "n";
        key = "K";
        action = "I";
        desc = "Insert at line start";
      }
      {
        mode = "n";
        key = "<leader>o";
        action = "za";
        desc = "Toggle fold";
      }
      {
        mode = "n";
        key = "s";
        action = "<nop>";
        desc = "Disabled";
      }

      {
        mode = "n";
        key = "<leader>ltd";
        lua = true;
        action = "function() vim.diagnostic.enable(not vim.diagnostic.is_enabled()) end";
        desc = "Toggle LSP diagnostics";
      }

      # ==================== Colemak Movement (normal-only) ====================
      {
        mode = "n";
        key = "U";
        action = "5k";
        desc = "Move up 5 lines";
      }
      {
        mode = "n";
        key = "E";
        action = "5j";
        desc = "Move down 5 lines";
      }
      {
        mode = "n";
        key = "W";
        action = "5w";
        desc = "Move 5 words forward";
      }
      {
        mode = "n";
        key = "B";
        action = "5b";
        desc = "Move 5 words backward";
      }
      {
        mode = "n";
        key = "h";
        action = "e";
        desc = "Move to end of word";
      }
      {
        mode = "n";
        key = "<C-U>";
        action = "5<C-y>";
        desc = "Scroll up 5 lines";
      }
      {
        mode = "n";
        key = "<C-E>";
        action = "5<C-e>";
        desc = "Scroll down 5 lines";
      }
      {
        mode = "n";
        key = "\\v";
        action = "v$h";
        desc = "Visual select to end of line";
      }

      # Explicit gx (the builtin once depended on netrw). <cfile> keeps URL
      # chars (?&=:%#) via 'isfname'.
      {
        mode = "n";
        key = "gx";
        lua = true;
        action = ''
          function()
            local target = vim.fn.expand("<cfile>")
            if target == "" then
              vim.notify("No URL under cursor", vim.log.levels.WARN)
              return
            end
            vim.ui.open(target)
          end
        '';
        desc = "Open URL under cursor";
      }

      # ==================== Buffer Navigation ====================
      {
        mode = "n";
        key = "<S-n>";
        action = ":BufferLineCyclePrev<CR>";
        desc = "Previous buffer";
      }
      {
        mode = "n";
        key = "<S-i>";
        action = ":BufferLineCycleNext<CR>";
        desc = "Next buffer";
      }
      {
        mode = "n";
        key = "<leader>bd";
        action = ":bdelete<CR>";
        desc = "Delete buffer";
      }
      {
        mode = "n";
        key = "<leader>bD";
        action = ":bdelete!<CR>";
        desc = "Force delete buffer";
      }
      {
        mode = "n";
        key = "<leader>bp";
        action = ":BufferLineTogglePin<CR>";
        desc = "Pin buffer";
      }
      {
        mode = "n";
        key = "<leader>bo";
        action = ":BufferLineCloseOthers<CR>";
        desc = "Close other buffers";
      }

      # ==================== Insert Mode ====================
      {
        mode = "i";
        key = "<C-a>";
        action = "<ESC>A";
        desc = "Go to end of line";
      }

      # ==================== Terminal Mode ====================
      {
        mode = "t";
        key = "<C-N>";
        action = "<C-\\><C-N>";
        desc = "Exit terminal mode";
      }
      {
        mode = "t";
        key = "<C-O>";
        action = "<C-\\><C-N><C-O>";
        desc = "Terminal normal + jump";
      }

      # ==================== Command Mode ====================
      {
        mode = "c";
        key = "<C-a>";
        action = "<Home>";
        desc = "Go to command start";
      }
      {
        mode = "c";
        key = "<C-e>";
        action = "<End>";
        desc = "Go to command end";
      }
      {
        mode = "c";
        key = "<C-p>";
        action = "<Up>";
        desc = "Previous command";
      }
      {
        mode = "c";
        key = "<C-n>";
        action = "<Down>";
        desc = "Next command";
      }
      {
        mode = "c";
        key = "<C-b>";
        action = "<Left>";
        desc = "Move left";
      }
      {
        mode = "c";
        key = "<C-f>";
        action = "<Right>";
        desc = "Move right";
      }
      {
        mode = "c";
        key = "<M-b>";
        action = "<S-Left>";
        desc = "Move word left";
      }
      {
        mode = "c";
        key = "<M-w>";
        action = "<S-Right>";
        desc = "Move word right";
      }

      # ==================== Window Management ====================
      {
        mode = "n";
        key = "<leader>ww";
        action = "<C-w>w";
        desc = "Next window";
      }
      {
        mode = "n";
        key = "<leader>wu";
        action = "<C-w>k";
        desc = "Window up";
      }
      {
        mode = "n";
        key = "<leader>we";
        action = "<C-w>j";
        desc = "Window down";
      }
      {
        mode = "n";
        key = "<leader>wn";
        action = "<C-w>h";
        desc = "Window left";
      }
      {
        mode = "n";
        key = "<leader>wi";
        action = "<C-w>l";
        desc = "Window right";
      }
      {
        mode = "n";
        key = "qf";
        action = "<C-w>o";
        desc = "Close other windows";
      }

      # Window splitting
      {
        mode = "n";
        key = "wsu";
        action = ":set nosplitbelow<CR>:split<CR>:set splitbelow<CR>";
        desc = "Split up";
      }
      {
        mode = "n";
        key = "wse";
        action = ":set splitbelow<CR>:split<CR>";
        desc = "Split down";
      }
      {
        mode = "n";
        key = "wsn";
        action = ":set nosplitright<CR>:vsplit<CR>:set splitright<CR>";
        desc = "Split left";
      }
      {
        mode = "n";
        key = "wsi";
        action = ":set splitright<CR>:vsplit<CR>";
        desc = "Split right";
      }
      {
        mode = "n";
        key = "wv";
        action = ":set splitright<CR>:vsplit<CR>";
        desc = "Split right";
      }
      {
        mode = "n";
        key = "wh";
        action = ":set splitbelow<CR>:split<CR>";
        desc = "Split down";
      }

      # Window resizing
      {
        mode = "n";
        key = "<Up>";
        action = ":res +5<CR>";
        desc = "Increase height";
      }
      {
        mode = "n";
        key = "<Down>";
        action = ":res -5<CR>";
        desc = "Decrease height";
      }
      {
        mode = "n";
        key = "<Left>";
        action = ":vertical resize-5<CR>";
        desc = "Decrease width";
      }
      {
        mode = "n";
        key = "<Right>";
        action = ":vertical resize+5<CR>";
        desc = "Increase width";
      }

      # Window layout
      {
        mode = "n";
        key = "wsh";
        action = "<C-w>t<C-w>K";
        desc = "Horizontal layout";
      }
      {
        mode = "n";
        key = "wsv";
        action = "<C-w>t<C-w>H";
        desc = "Vertical layout";
      }
      {
        mode = "n";
        key = "wsrh";
        action = "<C-w>b<C-w>K";
        desc = "Rotate horizontal";
      }
      {
        mode = "n";
        key = "wsrv";
        action = "<C-w>b<C-w>H";
        desc = "Rotate vertical";
      }
    ];
  };
}
