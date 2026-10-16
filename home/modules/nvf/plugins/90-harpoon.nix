# home/modules/nvf/plugins/90-harpoon.nix
#
# Pin a handful of files and jump between them directly, without going
# through the bufferline or a telescope picker.
#
# All five mappings are overridden. nvf's defaults are <C-e> to list and
# <C-j>/<C-k>/<C-l>/<C-;> for the slots; <C-e> in particular would shadow
# "scroll down 5 lines" from ../90-keymaps.nix, and ctrl-pairs in general
# sit badly with the colemak layout. Leader-prefixed equivalents instead.

{ ... }:

{
  config.vim.navigation.harpoon = {
    enable = true;

    mappings = {
      markFile = "<leader>a";
      listMarks = "<leader>A";
      file1 = "<leader>1";
      file2 = "<leader>2";
      file3 = "<leader>3";
      file4 = "<leader>4";
    };
  };
}
