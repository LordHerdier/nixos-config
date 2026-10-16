# home/modules/nvf/plugins/99-undotree.nix
#
# Browse the undo history as a tree, including branches that a linear
# `u` / `<C-r>` walk cannot reach. Pairs with the persistent undofile
# enabled in ../00-options.nix -- without that, the tree is empty on every
# fresh session.

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
