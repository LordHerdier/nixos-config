# home/modules/nvf/plugins/60-outline.nix
#
# Structural views: aerial for a symbol outline of the current buffer,
# dropbar for the winbar breadcrumb trail.

{ ... }:

{
  # Toggles on `gO` (nvf default).
  config.vim.utility.outline.aerial-nvim.enable = true;

  # Breadcrumbs are per-window winbar, so they coexist with the global
  # statusline set via laststatus=3 in ../00-options.nix.
  config.vim.ui.dropbar-nvim.enable = true;

  config.vim.keymaps = [
    {
      mode = "n";
      key = "<leader>;";
      action = "<cmd>lua require('dropbar.api').pick()<CR>";
      desc = "Pick from breadcrumbs";
    }
  ];
}
