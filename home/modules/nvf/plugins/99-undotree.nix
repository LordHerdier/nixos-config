# home/modules/nvf/plugins/99-undotree.nix
#
# Undo history as a tree, including branches linear undo/redo can't reach.
# Pairs with the persistent undofile in ../00-options.nix.

{ ... }:

{
  config.vim.utility.undotree.enable = true;

  config.vim.keymaps = [
    {
      mode = "n";
      key = "<leader>u";
      action = "<cmd>UndotreeToggle<CR>";
      desc = "Toggle undo tree";
    }
  ];
}
