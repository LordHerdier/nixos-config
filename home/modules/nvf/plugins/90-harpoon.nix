# home/modules/nvf/plugins/90-harpoon.nix
#
# Pin a handful of files and jump between them directly.
#
# Leader mappings instead of nvf's <C-e> / <C-j> <C-k> <C-l> <C-;>: <C-e>
# would shadow "scroll down 5 lines" (../90-keymaps.nix), and ctrl-pairs
# sit badly with colemak.

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
