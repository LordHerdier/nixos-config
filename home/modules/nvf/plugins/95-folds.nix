# home/modules/nvf/plugins/95-folds.nix
#
# LSP/treesitter-aware folding. Replaces the default foldmethod, so
# <leader>o (toggle fold, ../90-keymaps.nix) starts acting on real syntactic
# regions rather than indentation guesses.
#
# The fold* options this depends on are set in ../00-options.nix.

{ lib, ... }:

{
  config.vim.ui.nvim-ufo = {
    enable = true;

    setupOpts = {
      # Prefer treesitter's fold regions, falling back to indent. The stock
      # provider chain leads with the LSP, which means no folds at all in a
      # buffer whose server does not implement foldingRange, and none at
      # startup before the server attaches.
      provider_selector = lib.generators.mkLuaInline ''
        function(_, _, _)
          return { "treesitter", "indent" }
        end
      '';
    };
  };

  # ufo supplies its own fold-all / unfold-all; the built-in zR/zM do not
  # know about its providers.
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
