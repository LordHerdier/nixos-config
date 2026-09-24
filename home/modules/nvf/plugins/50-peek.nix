# home/modules/nvf/plugins/50-peek.nix

{ pkgs, ... }:

{
  config.vim.extraPlugins.peek-nvim = {
    package = pkgs.vimPlugins.peek-nvim;
  };

  config.vim.luaConfigRC.peek-nvim = # lua
    ''
      require("peek").setup()
    '';

  config.vim.keymaps = [
    {
      mode = "n";
      key = "<leader>md";
      action = "<cmd>PeekOpen<CR>";
      desc = "Preview markdown";
    }
  ];
}
