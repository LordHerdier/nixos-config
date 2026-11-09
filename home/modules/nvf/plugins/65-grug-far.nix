# home/modules/nvf/plugins/65-grug-far.nix
#
# Project-wide find & replace. Telescope's live_grep can find across a repo
# but cannot rewrite; this covers the replace half.

{ ... }:

{
  config.vim.utility.grug-far-nvim.enable = true;

  config.vim.keymaps = [
    {
      mode = "n";
      key = "<leader>sr";
      action = "<cmd>GrugFar<CR>";
      desc = "Search & replace in project";
    }
    {
      # Literal `:` rather than <cmd> so Vim prefixes the '<,'> range
      # GrugFarWithin needs. (nvf lazy-loads grug-far only on GrugFar and
      # GrugFarWithin, so other commands wouldn't load it.)
      mode = "x";
      key = "<leader>sr";
      action = ":GrugFarWithin<CR>";
      desc = "Search & replace within selection";
    }
  ];
}
