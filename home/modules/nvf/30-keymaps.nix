# home/modules/nvf/30-keymaps.nix

# Note: editing with nvim and auto formatter: might want to use
# `:noautocmd w` since the formatting can get... weird with this one

{ ... }:

{
  config.vim.globals = {
    mapleader = " ";
  };

  config.vim = {
    keymaps = [
      # ==================== Basic ====================
      { mode = "n"; key = ";";  action = ":";   desc = "Enter command mode"; }
      { mode = "n"; key = "Q";  action = ":q<CR>"; desc = "Quit"; }
      { mode = "n"; key = "S";  action = ":w<CR>"; desc = "Save"; }
      { mode = "n"; key = "l";  action = "u";   desc = "Undo"; }
      { mode = "n"; key = "k";  action = "i";   desc = "Insert mode"; }
      { mode = "n"; key = "K";  action = "I";   desc = "Insert at line start"; }
      { mode = "n"; key = "<leader>o"; action = "za"; desc = "Toggle fold"; }
      { mode = "n"; key = "s";  action = "<nop>"; desc = "Disabled"; }

      # ==================== Colemak Movement ====================
      { mode = "n"; key = "u";  action = "k";   desc = "Move up"; }
      { mode = "n"; key = "e";  action = "j";   desc = "Move down"; }
      { mode = "n"; key = "n";  action = "h";   desc = "Move left"; }
      { mode = "n"; key = "i";  action = "l";   desc = "Move right"; }
      { mode = "n"; key = "gu"; action = "gk";  desc = "Move up (wrapped)"; }
      { mode = "n"; key = "ge"; action = "gj";  desc = "Move down (wrapped)"; }
      { mode = "n"; key = "U";  action = "5k";  desc = "Move up 5 lines"; }
      { mode = "n"; key = "E";  action = "5j";  desc = "Move down 5 lines"; }
      { mode = "n"; key = "N";  action = "0";   desc = "Go to line start"; }
      { mode = "n"; key = "I";  action = "$";   desc = "Go to line end"; }
      { mode = "n"; key = "W";  action = "5w";  desc = "Move 5 words forward"; }
      { mode = "n"; key = "B";  action = "5b";  desc = "Move 5 words backward"; }
      { mode = "n"; key = "h";  action = "e";   desc = "Move to end of word"; }
      { mode = "n"; key = "<C-U>"; action = "5<C-y>"; desc = "Scroll up 5 lines"; }
      { mode = "n"; key = "<C-E>"; action = "5<C-e>"; desc = "Scroll down 5 lines"; }
      { mode = "n"; key = "\\v"; action = "v$h"; desc = "Visual select to end of line"; }

      # Visual/operator mode Colemak movement
      { mode = "v"; key = "u";  action = "k"; }
      { mode = "v"; key = "e";  action = "j"; }
      { mode = "v"; key = "n";  action = "h"; }
      { mode = "v"; key = "i";  action = "l"; }
      { mode = "v"; key = "gu"; action = "gk"; }
      { mode = "v"; key = "ge"; action = "gj"; }
      { mode = "x"; key = "u";  action = "k"; }
      { mode = "x"; key = "e";  action = "j"; }
      { mode = "x"; key = "n";  action = "h"; }
      { mode = "x"; key = "i";  action = "l"; }
      { mode = "x"; key = "gu"; action = "gk"; }
      { mode = "x"; key = "ge"; action = "gj"; }
      { mode = "o"; key = "u";  action = "k"; }
      { mode = "o"; key = "e";  action = "j"; }
      { mode = "o"; key = "n";  action = "h"; }
      { mode = "o"; key = "i";  action = "l"; }

      # ==================== Insert Mode ====================
      { mode = "i"; key = "<C-a>"; action = "<ESC>A"; desc = "Go to end of line"; }

      # ==================== Terminal Mode ====================
      { mode = "t"; key = "<C-N>"; action = "<C-\\><C-N>";    desc = "Exit terminal mode"; }
      { mode = "t"; key = "<C-O>"; action = "<C-\\><C-N><C-O>"; desc = "Terminal normal + jump"; }

      # ==================== Command Mode ====================
      { mode = "c"; key = "<C-a>"; action = "<Home>";    desc = "Go to command start"; }
      { mode = "c"; key = "<C-e>"; action = "<End>";     desc = "Go to command end"; }
      { mode = "c"; key = "<C-p>"; action = "<Up>";      desc = "Previous command"; }
      { mode = "c"; key = "<C-n>"; action = "<Down>";    desc = "Next command"; }
      { mode = "c"; key = "<C-b>"; action = "<Left>";    desc = "Move left"; }
      { mode = "c"; key = "<C-f>"; action = "<Right>";   desc = "Move right"; }
      { mode = "c"; key = "<M-b>"; action = "<S-Left>";  desc = "Move word left"; }
      { mode = "c"; key = "<M-w>"; action = "<S-Right>"; desc = "Move word right"; }

      # ==================== Window Management ====================
      { mode = "n"; key = "<leader>ww"; action = "<C-w>w"; desc = "Next window"; }
      { mode = "n"; key = "<leader>wu"; action = "<C-w>k"; desc = "Window up"; }
      { mode = "n"; key = "<leader>we"; action = "<C-w>j"; desc = "Window down"; }
      { mode = "n"; key = "<leader>wn"; action = "<C-w>h"; desc = "Window left"; }
      { mode = "n"; key = "<leader>wi"; action = "<C-w>l"; desc = "Window right"; }
      { mode = "n"; key = "qf";         action = "<C-w>o"; desc = "Close other windows"; }

      # Window splitting
      { mode = "n"; key = "su"; action = ":set nosplitbelow<CR>:split<CR>:set splitbelow<CR>"; desc = "Split up"; }
      { mode = "n"; key = "se"; action = ":set splitbelow<CR>:split<CR>";                      desc = "Split down"; }
      { mode = "n"; key = "sn"; action = ":set nosplitright<CR>:vsplit<CR>:set splitright<CR>"; desc = "Split left"; }
      { mode = "n"; key = "si"; action = ":set splitright<CR>:vsplit<CR>";                     desc = "Split right"; }

      { mode = "n"; key = "wv"; action = ":set splitright<CR>:vsplit<CR>";                     desc = "Split right"; }
      { mode = "n"; key = "wh"; action = ":set splitbelow<CR>:split<CR>";                      desc = "Split down"; }

      # Window resizing
      { mode = "n"; key = "<Up>";    action = ":res +5<CR>";           desc = "Increase height"; }
      { mode = "n"; key = "<Down>";  action = ":res -5<CR>";           desc = "Decrease height"; }
      { mode = "n"; key = "<Left>";  action = ":vertical resize-5<CR>"; desc = "Decrease width"; }
      { mode = "n"; key = "<Right>"; action = ":vertical resize+5<CR>"; desc = "Increase width"; }

      # Window layout
      { mode = "n"; key = "sh";  action = "<C-w>t<C-w>K"; desc = "Horizontal layout"; }
      { mode = "n"; key = "sv";  action = "<C-w>t<C-w>H"; desc = "Vertical layout"; }
      { mode = "n"; key = "srh"; action = "<C-w>b<C-w>K"; desc = "Rotate horizontal"; }
      { mode = "n"; key = "srv"; action = "<C-w>b<C-w>H"; desc = "Rotate vertical"; }
    ];
  };
}
