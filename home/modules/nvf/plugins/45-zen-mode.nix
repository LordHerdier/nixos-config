# home/modules/nvf/plugins/45-zen-mode.nix

{ pkgs, ... }:

{
  config.vim.extraPlugins.zen-mode = {
    package = pkgs.vimPlugins.zen-mode-nvim;
  };

  config.vim.extraPlugins.twilight = {
    package = pkgs.vimPlugins.twilight-nvim;
  };

  config.vim.extraPlugins.vim-pencil = {
    package = pkgs.vimPlugins.vim-pencil;
  };

  config.vim.luaConfigRC.zen-mode = # lua
    ''
      require("twilight").setup({})

      -- <leader>Z sets this so twilight + pencil only accompany that entry point
      local writing_mode = false

      require("zen-mode").setup({
        on_open = function()
          if writing_mode then
            vim.cmd("TwilightEnable")
            vim.cmd("PencilSoft")
            local buf = vim.api.nvim_get_current_buf()
            vim.treesitter.stop(buf)
            require("cmp").setup.buffer({ enabled = false })
            vim.diagnostic.enable(false, { bufnr = buf })
          end
        end,
        on_close = function()
          if writing_mode then
            vim.cmd("TwilightDisable")
            vim.cmd("PencilOff")
            local buf = vim.api.nvim_get_current_buf()
            pcall(vim.treesitter.start, buf)
            require("cmp").setup.buffer({ enabled = true })
            vim.diagnostic.enable(true, { bufnr = buf })
            -- PencilOff leaves its buffer-local movement remaps behind (it
            -- also remaps colemak e/u via Mapkey), so clear them ourselves.
            for _, mode in ipairs({ "n", "v" }) do
              for _, key in ipairs({ "e", "u", "j", "k", "gj", "gk", "g0", "g$", "0", "$" }) do
                pcall(vim.keymap.del, mode, key, { buffer = buf })
              end
            end
            writing_mode = false
          end
        end,
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

      vim.api.nvim_create_user_command("WritingMode", function()
        writing_mode = not require("zen-mode.view").is_open()
        require("zen-mode").toggle()
      end, {})
    '';

  config.vim.keymaps = [
    {
      mode = "n";
      key = "<leader>z";
      action = "<cmd>ZenMode<CR>";
      desc = "Toggle Zen Mode";
    }
    {
      mode = "n";
      key = "<leader>Z";
      action = "<cmd>WritingMode<CR>";
      desc = "Toggle Zen + Twilight + Pencil (distractions off)";
    }
  ];
}
