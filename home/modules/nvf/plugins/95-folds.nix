# home/modules/nvf/plugins/95-folds.nix
#
# Treesitter-aware folding for <leader>o (../90-keymaps.nix) and z*.
# The fold* options it depends on are in ../00-options.nix.

{ lib, ... }:

{
  config.vim.ui.nvim-ufo = {
    enable = true;

    setupOpts = {
      # Treesitter, then indent. The stock chain leads with LSP, which
      # gives no folds before the server attaches or if it lacks
      # foldingRange.
      provider_selector = lib.generators.mkLuaInline ''
        function(_, _, _)
          return { "treesitter", "indent" }
        end
      '';
    };
  };

  # The built-in zR/zM don't know about ufo's providers.
  config.vim.keymaps = [
    {
      mode = "n";
      key = "zR";
      action = "<cmd>lua require('ufo').openAllFolds()<CR>";
      desc = "Open all folds";
    }
    {
      mode = "n";
      key = "zM";
      action = "<cmd>lua require('ufo').closeAllFolds()<CR>";
      desc = "Close all folds";
    }
  ];
}
