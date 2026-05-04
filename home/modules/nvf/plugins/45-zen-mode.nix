# home/modules/nvf/plugins/45-zen-mode.nix

{ pkgs, ... }:

{
  config.vim.extraPlugins.zen-mode = {
    package = pkgs.vimPlugins.zen-mode-nvim;
  };

  config.vim.luaConfigRC.zen-mode = # lua
    ''
      require("zen-mode").setup({
        window = {
          width = 0.70,
          height = 1,
          options = {
            signcolumn = "no",
            cursorline = false, 
            number = false,
            relativenumber = false,
          },
        },
      })
    '';

  config.vim.keymaps = [
    {
      mode = "n";
      key = "<leader>z";
      action = "<cmd>ZenMode<CR>";
      desc = "Toggle Zen Mode";
    }
  ];
}
